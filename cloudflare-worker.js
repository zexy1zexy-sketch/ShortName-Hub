const OWNER="zexy1zexy-sketch", REPO="ShortName-Hub", BRANCH="main";
const REPORT_PATH="scanner-reports/latest.txt", MAX_REPORT_CHARS=100000;
const ALLOWED_MODULES=new Set(["Main.lua","Config.lua","GUI.lua","Theme.lua","Presence.lua","KeySystem.lua","LoadingScreen.lua","Logger.lua","RemoteLogger.lua","NPC.lua","Scythe.lua","SpyAdapter.lua","Teleport.lua","ThanksgivingScanner.lua","UniversalObjectScanner.lua","UniversalInstanceInspector.lua","UniversalStructureScanner.lua","UniversalLiveObserver.lua"]);
function cors(){return {"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"GET, POST, PATCH, DELETE, OPTIONS","Access-Control-Allow-Headers":"Content-Type, x-upload-key, x-read-key, x-owner-session, x-owner-secret","Access-Control-Max-Age":"86400"};}
function reply(body,status=200,headers={}){return new Response(typeof body==="string"?body:JSON.stringify(body),{status,headers:{...cors(),"Content-Type":"application/json; charset=utf-8",...headers}});}
function b64utf8(s){const b=new TextEncoder().encode(s);let v="";for(let i=0;i<b.length;i++)v+=String.fromCharCode(b[i]);return btoa(v);}
async function gh(path,token,options={}){return fetch("https://api.github.com"+path,{...options,headers:{"Authorization":"Bearer "+token,"User-Agent":"ShortNameHub-Worker","Accept":"application/vnd.github+json","X-GitHub-Api-Version":"2022-11-28",...(options.headers||{})}});}
async function saveReport(report,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 const p="/repos/"+OWNER+"/"+REPO+"/contents/"+REPORT_PATH;
 const old=await gh(p+"?ref="+BRANCH,env.GITHUB_TOKEN);let sha;
 if(old.ok)sha=(await old.json()).sha;else if(old.status!==404)throw new Error("GitHub read failed ("+old.status+"): "+await old.text());
 const body={message:"Update latest ShortName Hub scanner report",content:b64utf8(report),branch:BRANCH};if(sha)body.sha=sha;
 const put=await gh(p,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub save failed ("+put.status+"): "+await put.text());return await put.json();
}
async function saveGameReport(report,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 const stamp=new Date().toISOString().replace(/[:.]/g,"-");
 const path="game-reports/inbox/"+stamp+"-"+crypto.randomUUID()+".txt";
 const content=report.trim()+"\n\nReceived by ShortName Hub: "+new Date().toISOString()+"\n";
 const body={message:"Add manually approved game detection report",content:b64utf8(content),branch:BRANCH};
 const put=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+path,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub game report save failed ("+put.status+"): "+await put.text());
 return {path,commit:(await put.json()).commit?.sha||null};
}
async function saveSnapshotReport(report,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 let parsed;try{parsed=JSON.parse(report);}catch{throw new Error("Snapshot report is not valid JSON");}
 if(!parsed||parsed.reportType!=="SHORTNAME_HUB_OBSERVATION_SNAPSHOT"||!Array.isArray(parsed.snapshots)||parsed.snapshots.length>100)throw new Error("Invalid snapshot report format");
 if(new TextEncoder().encode(report).length>150000)throw new Error("Snapshot report exceeds 150 KB");
 const stamp=new Date().toISOString().replace(/[:.]/g,"-");
 const path="game-reports/snapshots/"+stamp+"-"+crypto.randomUUID()+".json";
 const body={message:"Add observation snapshot report",content:b64utf8(report+"\n"),branch:BRANCH};
 const put=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+path,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub snapshot save failed ("+put.status+"): "+await put.text());
 return {path,commit:(await put.json()).commit?.sha||null};
}
async function saveFeedback(message,username,userId,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 const stamp=new Date().toISOString().replace(/[:.]/g,"-");
 const path="feedback/inbox/"+stamp+"-"+crypto.randomUUID()+".txt";
 const safeUsername=cleanText(username,20)||"Unknown";
 const safeUserId=Number.isSafeInteger(Number(userId))&&Number(userId)>0?String(Number(userId)):"Unknown";
 const content="SHORTNAME HUB FEEDBACK\nReceived: "+new Date().toISOString()+"\nUsername: "+safeUsername+"\nUser ID: "+safeUserId+"\nIdentity source: Roblox client-reported\n\n"+message+"\n";
 const body={message:"Add ShortName Hub feedback",content:b64utf8(content),branch:BRANCH};
 const put=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+path,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub feedback save failed ("+put.status+"): "+await put.text());
 return {path,commit: (await put.json()).commit?.sha||null};
}

const PRESENCE_PREFIX="presence:";
async function createOwnerPair(request,env){
 const supplied=request.headers.get("x-owner-secret")||"";
 const ip=request.headers.get("CF-Connecting-IP")||"unknown";
 const digest=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(ip));
 const ipHash=Array.from(new Uint8Array(digest)).map(x=>x.toString(16).padStart(2,"0")).join("").slice(0,24);
 const attemptKey="owner-login-attempts:"+ipHash;
 const attempts=await env.REPORTS.get(attemptKey,"json")||{count:0,blockedUntil:0};
 if(Number(attempts.blockedUntil||0)>Date.now())return reply({ok:false,error:"Too many failed owner login attempts. Try again later."},429);
 if(!(await secretMatches(supplied,env.OWNER_SECRET))){
  const count=Number(attempts.count||0)+1;
  const blockedUntil=count>=5?Date.now()+900000:0;
  await env.REPORTS.put(attemptKey,JSON.stringify({count,blockedUntil}),{expirationTtl:900});
  return reply({ok:false,error:"Invalid owner secret"},401);
 }
 await env.REPORTS.delete(attemptKey);
 const token=Array.from(crypto.getRandomValues(new Uint8Array(32)),b=>b.toString(16).padStart(2,"0")).join("");
 await env.REPORTS.put("owner-session:"+token,JSON.stringify({owner:true,createdAt:Date.now()}),{expirationTtl:1800});
 return reply({ok:true,session:token,expiresInSeconds:1800},200,{"Cache-Control":"no-store"});
}
async function exchangeOwnerPair(request,env){
 const body=await request.json().catch(()=>null);
 const code=String(body?.code||"").replace(/\D/g,"");
 if(code.length!==6)return reply({ok:false,error:"Enter the six-digit pairing code"},400);
 const key="owner-pair:"+code;
 const pair=await env.REPORTS.get(key,"json");
 if(!pair)return reply({ok:false,error:"Pairing code expired or already used"},401);
 await env.REPORTS.delete(key);
 const token=Array.from(crypto.getRandomValues(new Uint8Array(32)),b=>b.toString(16).padStart(2,"0")).join("");
 await env.REPORTS.put("owner-session:"+token,JSON.stringify({email:pair.email,createdAt:Date.now()}),{expirationTtl:1800});
 return reply({ok:true,session:token,expiresInSeconds:1800});
}
async function requireOwnerSession(request,env){
 const token=request.headers.get("x-owner-session")||"";
 if(!/^[a-f0-9]{64}$/.test(token))return await rejectAdminAttempt(request,env);
 const session=await env.REPORTS.get("owner-session:"+token,"json");
 if(!session||session.owner!==true)return await rejectAdminAttempt(request,env);
 return null;
}

function cleanText(value,max=80){return typeof value==="string"?value.replace(/[\u0000-\u001f]/g,"").trim().slice(0,max):"";}
async function secretMatches(provided,expected){
 if(typeof provided!=="string"||typeof expected!=="string"||!expected)return false;
 const encoder=new TextEncoder();
 const a=await crypto.subtle.digest("SHA-256",encoder.encode(provided));
 const b=await crypto.subtle.digest("SHA-256",encoder.encode(expected));
 return crypto.subtle.timingSafeEqual(new Uint8Array(a),new Uint8Array(b));
}

async function rejectAdminAttempt(request,env){
 const url=new URL(request.url);
 const ip=request.headers.get("CF-Connecting-IP")||"unknown";
 const digest=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(ip));
 const ipHash=Array.from(new Uint8Array(digest)).map(x=>x.toString(16).padStart(2,"0")).join("").slice(0,24);
 const event={eventType:"unauthorized-admin-request",source:"worker-verified-rejection",username:"Unknown",userId:null,details:"Rejected "+request.method+" "+url.pathname+"; caller identity is not verified; ipHash="+ipHash,placeId:0,createdAt:new Date().toISOString(),identitySource:"Unknown; request rejected before identity verification"};
 await env.REPORTS.put("security:"+Date.now()+":"+crypto.randomUUID(),JSON.stringify(event),{expirationTtl:7776000});
 return reply({ok:false,error:"Unauthorized"},401);
}
async function savePresence(body,env){
 const id=Number(body.userId);
 if(!Number.isSafeInteger(id)||id<=0)throw new Error("Invalid Roblox user ID");
 const key=PRESENCE_PREFIX+id;
 const old=await env.REPORTS.get(key,"json");
 const record={
  userId:id,
  username:cleanText(body.username,32)||("User "+id),
  displayName:cleanText(body.displayName,32)||cleanText(body.username,32)||("User "+id),
  gameName:cleanText(body.gameName,100)||"Unknown experience",
  placeId:Number.isSafeInteger(Number(body.placeId))?Number(body.placeId):0,
  universeId:Number.isSafeInteger(Number(body.universeId))?Number(body.universeId):0,
  executor:cleanText(body.executor,60)||"Unknown / unavailable",
  lastSeen:Date.now(),
  rank:["Member","Premium","Staff"].includes(old?.rank)?old.rank:"Member"
 };
 await env.REPORTS.put(key,JSON.stringify(record));
 return {ok:true};
}
async function listPlayers(env){
 const players=[];
 let cursor;
 do{
  const page=await env.REPORTS.list({prefix:PRESENCE_PREFIX,limit:1000,...(cursor?{cursor}:{})});
  for(const item of page.keys||[]){
   const value=await env.REPORTS.get(item.name,"json");
   if(value)players.push({...value,online:(Date.now()-Number(value.lastSeen||0))<=90000});
   if(players.length>=5000)break;
  }
  cursor=page.list_complete?undefined:page.cursor;
 }while(cursor&&players.length<5000);
 players.sort((a,b)=>Number(b.online)-Number(a.online)||String(a.username).localeCompare(String(b.username)));
 return players;
}


async function saveSecurityEvent(event,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 const stamp=new Date().toISOString().replace(/[:.]/g,"-");
 const safe={
  eventType:cleanText(event.eventType,80)||"unspecified",
  source:cleanText(event.source,40)||"client-reported",
  userId:Number.isSafeInteger(Number(event.userId))&&Number(event.userId)>0?Number(event.userId):null,
  username:cleanText(event.username,32)||"Unknown",
  details:cleanText(event.details,1200),
  placeId:Number.isSafeInteger(Number(event.placeId))?Number(event.placeId):0,
  createdAt:new Date().toISOString(),
  identitySource:"Client-reported; not independently verified"
 };
 const path="security-reports/inbox/"+stamp+"-"+crypto.randomUUID()+".json";
 const body={message:"Add ShortName Hub security event",content:b64utf8(JSON.stringify(safe,null,2)+"\n"),branch:BRANCH};
 const put=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+path,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub security report save failed ("+put.status+")");
 await env.REPORTS.put("security:"+Date.now()+":"+crypto.randomUUID(),JSON.stringify(safe),{expirationTtl:7776000});
 return {path};
}
async function listSecurityEvents(env){
 const events=[];let cursor;
 do{
  const page=await env.REPORTS.list({prefix:"security:",limit:500,...(cursor?{cursor}:{})});
  for(const item of page.keys||[]){const value=await env.REPORTS.get(item.name,"json");if(value)events.push(value);if(events.length>=500)break;}
  cursor=page.list_complete?undefined:page.cursor;
 }while(cursor&&events.length<500);
 events.sort((a,b)=>String(b.createdAt).localeCompare(String(a.createdAt)));
 return events;
}
async function listBans(env){
 const bans=[];let cursor;
 do{
  const page=await env.REPORTS.list({prefix:"ban:",limit:500,...(cursor?{cursor}:{})});
  for(const item of page.keys||[]){
   const value=await env.REPORTS.get(item.name,"json");
   if(!value)continue;
   if(value.expiresAt!==null&&Number(value.expiresAt)<=Date.now()){await env.REPORTS.delete(item.name);continue;}
   bans.push(value);
  }
  cursor=page.list_complete?undefined:page.cursor;
 }while(cursor&&bans.length<5000);
 return bans;
}

async function serveModule(request,env){
 // Public, allowlisted module delivery. The GitHub token remains server-side.
 const name=new URL(request.url).searchParams.get("name")||"";
 if(!ALLOWED_MODULES.has(name))return reply({ok:false,error:"Module is not allowlisted"},400);
 if(!env.GITHUB_TOKEN)return reply({ok:false,error:"GITHUB_TOKEN secret is missing"},500);
 const r=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+name+"?ref="+BRANCH,env.GITHUB_TOKEN);
 if(!r.ok)return reply({ok:false,error:"GitHub module fetch failed",status:r.status,details:await r.text()},502);
 const data=await r.json();if(!data.content||data.encoding!=="base64")return reply({ok:false,error:"GitHub returned no base64 content"},502);
 const bin=atob(data.content.replace(/\s/g,"")),bytes=new Uint8Array(bin.length);for(let i=0;i<bin.length;i++)bytes[i]=bin.charCodeAt(i);
 return new Response(new TextDecoder().decode(bytes),{status:200,headers:{...cors(),"Content-Type":"text/plain; charset=utf-8","Cache-Control":"no-store","X-Module-Name":name}});
}
export default {async fetch(request,env,ctx){
 if(request.method==="OPTIONS")return new Response(null,{status:204,headers:cors()});
 const url=new URL(request.url);
 try{
  if(request.method==="GET"&&url.pathname==="/module")return await serveModule(request,env);
   if(request.method==="POST"&&url.pathname==="/owner-pair")return await createOwnerPair(request,env);
   if(request.method==="POST"&&url.pathname==="/owner-session")return await exchangeOwnerPair(request,env);
   if(request.method==="POST"&&url.pathname==="/presence"){
    const body=await request.json().catch(()=>null);
    if(!body||typeof body!=="object")return reply({ok:false,error:"Expected presence JSON"},400);
    return reply(await savePresence(body,env));
   }
   if(request.method==="POST"&&url.pathname==="/security-report"){
    if(!(await secretMatches(request.headers.get("x-upload-key")||"",env.UPLOAD_KEY)))return reply({ok:false,error:"Unauthorized"},401);
    const body=await request.json().catch(()=>null);
    if(!body||typeof body!=="object")return reply({ok:false,error:"Expected security event JSON"},400);
    const allowed=["client-integrity-warning","unauthorized-local-action","protection-tamper-suspected"];
    if(!allowed.includes(body.eventType))return reply({ok:false,error:"Unsupported security event type"},400);
    const saved=await saveSecurityEvent({...body,source:"client-reported"},env);
    return reply({ok:true,github:"saved",path:saved.path});
   }
   if(request.method==="GET"&&url.pathname==="/security-events"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    return reply({ok:true,events:await listSecurityEvents(env)});
   }
   if(request.method==="GET"&&url.pathname==="/bans"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    return reply({ok:true,bans:await listBans(env)});
   }
   if(request.method==="GET"&&url.pathname==="/players"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    return reply({ok:true,players:await listPlayers(env)});
   }
   if(request.method==="PATCH"&&url.pathname==="/ban"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    const body=await request.json().catch(()=>null);
    const id=Number(body?.userId),duration=body?.duration;
    if(!Number.isSafeInteger(id)||id<=0||id===7867608166||!["1d","30d","permanent"].includes(duration))return reply({ok:false,error:"Invalid user ID or ban duration"},400);
    const expiresAt=duration==="permanent"?null:Date.now()+(duration==="1d"?86400000:2592000000);
    const record={userId:id,duration,expiresAt,createdAt:Date.now()};
    await env.REPORTS.put("ban:"+id,JSON.stringify(record));
    return reply({ok:true,ban:record});
   }
   if(request.method==="DELETE"&&url.pathname==="/ban"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    const id=Number(url.searchParams.get("userId"));
    if(!Number.isSafeInteger(id)||id<=0)return reply({ok:false,error:"Invalid user ID"},400);
    await env.REPORTS.delete("ban:"+id);
    return reply({ok:true});
   }
   if(request.method==="GET"&&url.pathname==="/check-ban"){
    const id=Number(url.searchParams.get("userId"));
    if(!Number.isSafeInteger(id)||id<=0)return reply({ok:false,error:"Invalid user ID"},400);
    const ban=await env.REPORTS.get("ban:"+id,"json");
    if(!ban)return reply({ok:true,banned:false});
    if(ban.expiresAt!==null&&Number(ban.expiresAt)<=Date.now()){
      await env.REPORTS.delete("ban:"+id);
      return reply({ok:true,banned:false});
    }
    return reply({ok:true,banned:true,ban});
   }
   if(request.method==="PATCH"&&url.pathname==="/rank"){
    {const denied=await requireOwnerSession(request,env);if(denied)return denied;}
    const body=await request.json().catch(()=>null);
    const id=Number(body?.userId),rank=body?.rank;
    if(!Number.isSafeInteger(id)||id<=0||!["Member","Premium","Staff"].includes(rank))return reply({ok:false,error:"Invalid user ID or rank"},400);
    const key=PRESENCE_PREFIX+id,record=await env.REPORTS.get(key,"json");
    if(!record)return reply({ok:false,error:"Player has not registered presence yet"},404);
    record.rank=rank;await env.REPORTS.put(key,JSON.stringify(record));
    return reply({ok:true,player:record});
   }
  if(request.method==="GET"&&url.pathname==="/latest"){
   if(!env.READ_KEY||url.searchParams.get("key")!==env.READ_KEY)return reply({ok:false,error:"Unauthorized"},401);
   const report=await env.REPORTS.get("latest-report");if(report===null)return reply({ok:false,error:"No report uploaded yet"},404);
   return new Response(report,{status:200,headers:{...cors(),"Content-Type":"text/plain; charset=utf-8","Cache-Control":"no-store"}});
  }
  if(request.method==="POST"&&url.pathname==="/upload"){
   if(!(await secretMatches(request.headers.get("x-upload-key")||"",env.UPLOAD_KEY)))return reply({ok:false,error:"Unauthorized"},401);
   const body=await request.json().catch(()=>null);if(!body||typeof body.report!=="string")return reply({ok:false,error:"Expected JSON body with report string"},400);
   if(body.report.length>MAX_REPORT_CHARS)return reply({ok:false,error:"Report too large"},413);
   await env.REPORTS.put("latest-report",body.report);const saved=await saveReport(body.report,env);
   return reply({ok:true,characters:body.report.length,github:"saved",commit:saved.commit?.sha||null});
  }
  if(request.method==="POST"&&url.pathname==="/snapshot-report"){
   if(!(await secretMatches(request.headers.get("x-upload-key")||"",env.UPLOAD_KEY)))return reply({ok:false,error:"Unauthorized"},401);
   const body=await request.json().catch(()=>null);
   if(!body||typeof body.report!=="string")return reply({ok:false,error:"Expected JSON body with report string"},400);
   const saved=await saveSnapshotReport(body.report,env);
   return reply({ok:true,github:"saved",path:saved.path,commit:saved.commit});
  }
  if(request.method==="POST"&&url.pathname==="/game-report"){
   if(!(await secretMatches(request.headers.get("x-upload-key")||"",env.UPLOAD_KEY)))return reply({ok:false,error:"Unauthorized"},401);
   const body=await request.json().catch(()=>null);
   if(!body||typeof body.report!=="string")return reply({ok:false,error:"Expected JSON body with report string"},400);
   const report=body.report.trim();
   if(report.length<20||report.length>20000)return reply({ok:false,error:"Game report must be 20-20,000 characters"},400);
   const saved=await saveGameReport(report,env);
   return reply({ok:true,github:"saved",path:saved.path,commit:saved.commit});
  }
  if(request.method==="POST"&&url.pathname==="/feedback"){
   const body=await request.json().catch(()=>null);
   if(!body||typeof body.message!=="string")return reply({ok:false,error:"Expected JSON body with message"},400);
   const message=body.message.trim();
   if(message.length<8||message.length>1500)return reply({ok:false,error:"Feedback must be 8-1,500 characters"},400);
   const username=cleanText(body.username,20);
   const userId=Number(body.userId);
   if(!username||!Number.isSafeInteger(userId)||userId<=0)return reply({ok:false,error:"Valid Roblox username and user ID are required"},400);
   const ip=request.headers.get("CF-Connecting-IP")||"unknown";
   const rateKey="feedback-cooldown:"+ip;
   if(await env.REPORTS.get(rateKey))return reply({ok:false,error:"Please wait a minute before sending another idea"},429);
   const saved=await saveFeedback(message,username,userId,env);
   await env.REPORTS.put(rateKey,"1",{expirationTtl:60});
   return reply({ok:true,github:"saved",path:saved.path,commit:saved.commit});
  }
  return reply({ok:false,error:"Not found",routes:["GET /module?name=GUI.lua","POST /presence","GET /players","GET /bans","GET /security-events","POST /security-report","PATCH /rank","PATCH /ban","DELETE /ban","GET /check-ban","GET /latest?key=...","POST /upload","POST /game-report","POST /snapshot-report","POST /feedback"]},404);
 }catch(e){return reply({ok:false,error:"Worker error",details:String(e?.message||e)},500);}
}};