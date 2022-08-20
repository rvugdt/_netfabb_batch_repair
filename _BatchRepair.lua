wp = system:showdirectoryselectdialog(true, true, true)
if wp~="" then
   cp = wp.."_completed\\"
   wp = wp.."\\"
else
    system:messagedlg("directory not selected. script was stopped.")
    return 0
end;
wasrepaired = 0

if system:directoryexists(cp) then
       system:log("dir _completed exists")
else
       system:createdirectory(cp)
end;

function loadfile (filename)
  path,file,ext = string.match(filename, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  ext = ext:lower()
  system:log(ext)
  if ext == "stl" then
  	system:log("stl")
  	return system:loadstl (filename)
  elseif ext == "3ds" then
  	system:log("3ds")
  	return system:load3ds (filename)
  elseif ext == "3mf" then
  	system:log("3mf")
  	return system:load3mf(filename)
  elseif ext == "amf" then
  	system:log("amf")
  	return system:loadamf(filename)
  elseif ext == "gts" then
  	system:log("gts")
  	return system:loadgts(filename)
  elseif ext == "ncm" then
  	system:log("ncm")
  	return system:loadncm(filename)
  elseif ext == "obj" then
  	system:log("obj")
  	return system:loadobj(filename)
  elseif ext == "ply" then
  	system:log("ply")
  	return system:loadply(filename)
  elseif ext == "svx" then
  	system:log("svx")
  	return system:loadvoxel(filename)
  elseif ext == "vrml" then
  	system:log("vrml")
  	return system:loadvrml(filename)
  elseif ext == "wrl" then
  	system:log("wrl")
  	return system:loadvrml(filename)
  elseif ext == "x3d" then
  	system:log("x3d")
  	return system:loadx3d(filename)
  elseif ext == "x3db" then
  	system:log("x3db")
  	return system:loadx3d(filename)
  elseif ext == "zpr" then
    system:log("zpr")
    return system:loadzpr(filename)
  else
  	return nil
  end
end;

--[[
function loadcadfile (filename, root)
  path,file,ext = string.match(filename, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  ext = ext:lower()
  system:log(ext)
  local iscadfile = false;
  if ext == "3dm" then
    iscadfile = true;
  elseif ext == "3dxml" then
  	iscadfile = true;
  elseif ext == "stp" then
  	iscadfile = true;
  elseif ext == "asm" then
  	iscadfile = true;
  elseif ext == "CATPart" then
    iscadfile = true;
  elseif ext == "cgr" then
    iscadfile = true;
  elseif ext == "dwg" then
    iscadfile = true;
  elseif ext == "FBX" then
   iscadfile = true;
  elseif ext == "g" then
   iscadfile = true;
  elseif ext == "iam" then
   iscadfile = true;
  elseif ext == "IGS" then
   iscadfile = true;
  elseif ext == "ipt" then
   iscadfile = true;
  elseif ext == "jt" then
   iscadfile = true;
  elseif ext == "model" then
   iscadfile = true;
  elseif ext == "neu" then
    iscadfile = true;
  elseif ext == "par" then
    iscadfile = true;
  elseif ext == "prt" then
    iscadfile = true;
  elseif ext == "prt" then
    iscadfile = true;
  elseif ext == "psm" then
    iscadfile = true;
  elseif ext == "rvt" then
    iscadfile = true;
  elseif ext == "sat" then
    iscadfile = true;
  elseif ext == "skp" then
    iscadfile = true;
  elseif ext == "sldprt" then
    iscadfile = true;
  elseif ext == "wire" then
    iscadfile = true;
  elseif ext == "x_b" then
    iscadfile = true;
  elseif ext == "x_t" then
    iscadfile = true;
  elseif ext == "xas" then
    iscadfile = true;
  elseif ext == "xpr" then
    iscadfile = true;
  end;


  if iscadfile then
    importer = system:createcadimport(0);
    model = importer:loadmodel(filename, 0.1, 20, 20)
    ANumberOfModels = model.entitycount;
    for i=0, ANumberOfModels-1 do
	  mesh = model:createsinglemesh(i);
      root:addmesh(mesh);
    end;
  end;
end;
]]

local root = tray.root;
--system:logtofile ('LUAoutput.txt');
xmlfilelist = system:getallfilesindirectory(wp);
system:log(xmlfilelist.childcount);
--xmlfilelist:savetofile('test.xml');
numberoffiles = xmlfilelist.childcount;
for i=0,numberoffiles-1 do
    xmlChild = xmlfilelist:getchildindexed(i);
    filename = xmlChild:getchildvalue ("filename");
    filenamestr = tostring(system:extractfilename(filename));
    system:log("file, wp,cp >>> "..filenamestr.." "..wp.." "..cp)
    if system:fileexists(cp..filenamestr) then
	system:log(filenamestr.." exists")
    else
	path,file,ext = string.match(filename, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	mesh = loadfile(filename);
        if mesh ~= nil then
          local traymesh = root:addmesh(mesh);
          traymesh.name = file;
          -- some repair processing there
          local luamesh   = traymesh.mesh;
	  if not luamesh.isok then
	     newMesh = luamesh:dupe();
	     local matrix = traymesh.matrix;
	     local oldname = traymesh.name;
	     local newname = oldname.."_(repaired)";
	     newMesh:repairsimple();
	     newMesh:applymatrix(matrix);
	     root:removemesh(traymesh);
	     root:addmesh(newMesh, newname);
	     completedfile = tostring(cp..filenamestr)
          --mesh:savetoasciistl(completedfile, filenamestr)
             if newMesh~=nil then
                newMesh:savetostl(completedfile)
                wasrepaired = wasrepaired +1
             end;
          end;
          root:removemesh(traymesh)
        --else
        --  loadcadfile(filename, root);
        end;
    end;
end;
system:messagedlg("Was repaired "..tostring(wasrepaired).." new files")
