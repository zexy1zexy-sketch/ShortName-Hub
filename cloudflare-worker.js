const OWNER="zexy1zexy-sketch", REPO="ShortName-Hub", BRANCH="main";
const REPORT_PATH="scanner-reports/latest.txt", MAX_REPORT_CHARS=100000;
const ALLOWED_MODULES=new Set(["Main.lua","Config.lua","GUI.lua","Presence.lua","KeySystem.lua","LoadingScreen.lua","Logger.lua","NPC.lua","Scythe.lua","SpyAdapter.lua","Teleport.lua","ThanksgivingScanner.lua","FightOnABaseplateScanner.lua", "FightOnABaseplateInspector.lua","FightOnABaseplateStructureScanner.lua"]);
function cors(){return {"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"GET, POST, PATCH, OPTIONS","Access-Control-Allow-Headers":"Content-Type, x-upload-key, x-read-key, x-admin-key","Access-Control-Max-Age":"86400"};}
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
async function saveFeedback(message,env){
 if(!env.GITHUB_TOKEN)throw new Error("GITHUB_TOKEN secret is missing");
 const stamp=new Date().toISOString().replace(/[:.]/g,"-");
 const path="feedback/inbox/"+stamp+"-"+crypto.randomUUID()+".txt";
 const content="SHORTNAME HUB FEEDBACK\nReceived: "+new Date().toISOString()+"\n\n"+message+"\n";
 const body={message:"Add ShortName Hub feedback",content:b64utf8(content),branch:BRANCH};
 const put=await gh("/repos/"+OWNER+"/"+REPO+"/contents/"+path,env.GITHUB_TOKEN,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(body)});
 if(!put.ok)throw new Error("GitHub feedback save failed ("+put.status+"): "+await put.text());
 return {path,commit: (await put.json()).commit?.sha||null};
}

const PRESENCE_PREFIX="presence:";
function cleanText(value,max=80){return typeof value==="string"?value.replace(/[\\u0000-\\u001f]/g,"").trim().slice(0,max):"";}
function isAdmin(request,env){return !!env.UPLOAD_KEY&&request.headers.get("x-admin-key")===env.UPLOAD_KEY;}
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
\nasync function serveModule(request,env){
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
export default {async fetch(request,env){
 if(request.method==="OPTIONS")return new Response(null,{status:204,headers:cors()});
 const url=new URL(request.url);
 try{
  if(request.method==="GET"&&url.pathname==="/module")return await serveModule(request,env);
   if(request.method==="POST"&&url.pathname==="/presence"){
    const body=await request.json().catch(()=>null);
    if(!body||typeof body!=="object")return reply({ok:false,error:"Expected presence JSON"},400);
    return reply(await savePresence(body,env));
   }
   if(request.method==="GET"&&url.pathname==="/players"){
    if(!isAdmin(request,env))return reply({ok:false,error:"Unauthorized"},401);
    return reply({ok:true,players:await listPlayers(env)});
   }
   if(request.method==="PATCH"&&url.pathname==="/rank"){
    if(!isAdmin(request,env))return reply({ok:false,error:"Unauthorized"},401);
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
   if(!env.UPLOAD_KEY||request.headers.get("x-upload-key")!==env.UPLOAD_KEY)return reply({ok:false,error:"Unauthorized"},401);
   const body=await request.json().catch(()=>null);if(!body||typeof body.report!=="string")return reply({ok:false,error:"Expected JSON body with report string"},400);
   if(body.report.length>MAX_REPORT_CHARS)return reply({ok:false,error:"Report too large"},413);
   await env.REPORTS.put("latest-report",body.report);const saved=await saveReport(body.report,env);
   return reply({ok:true,characters:body.report.length,github:"saved",commit:saved.commit?.sha||null});
  }
  if(request.method==="POST"&&url.pathname==="/feedback"){
   const body=await request.json().catch(()=>null);
   if(!body||typeof body.message!=="string")return reply({ok:false,error:"Expected JSON body with message"},400);
   const message=body.message.trim();
   if(message.length<8||message.length>1500)return reply({ok:false,error:"Feedback must be 8-1,500 characters"},400);
   const ip=request.headers.get("CF-Connecting-IP")||"unknown";
   const rateKey="feedback-cooldown:"+ip;
   if(await env.REPORTS.get(rateKey))return reply({ok:false,error:"Please wait a minute before sending another idea"},429);
   const saved=await saveFeedback(message,env);
   await env.REPORTS.put(rateKey,"1",{expirationTtl:60});
   return reply({ok:true,github:"saved",path:saved.path,commit:saved.commit});
  }
  return reply({ok:false,error:"Not found",routes:["GET /module?name=GUI.lua","POST /presence","GET /players","PATCH /rank","GET /latest?key=...","POST /upload","POST /feedback"]},404);
 }catch(e){return reply({ok:false,error:"Worker error",details:String(e?.message||e)},500);}
}};
