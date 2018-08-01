
cmd.register(0xB3);

function getData()
        dsaForce = 0;
        cellArea = 0.0034 * 0.0034;
        cellMaxVal = 3895;
        cellPressRange = 82200;
    if (finger.type(0) == "dsa") and (finger.type(1) == "dsa") then
        data0 = finger.data(0);
        data1 = finger.data(1);
        for y = 1, #data0.frame[1] do
            for x = 1, #data0.frame do
                dsaForce += data0.frame[x][y] + data1.frame[x][y];
            end
        end
    end   
    return dsaForce * (cellPressRange / cellMaxVal) * cellArea;
end 

function dsaGrip()

    id, forceGoal = cmd.read();
    mc.force(80);
    grasping.move(100, 80);
    mc.move(10, 20, 0x2);
    while (getData() < forceGoal) do
        sleep(1);
    end
    mc.force(mc.aforce());
    grasping.grasp(100, 50, 100);

    if cmd.online() then
        cmd.send(id, etob(E_SUCCESS));
    end

end

while true do
    if cmd.online() then
        if not pcall(dsaGrip) then
            print("Error occured")
            sleep(100)
        end
    else
        sleep(100)
    end
end



////////////////////////////////////////////////////////////

cmd.register(0xB3);

function getData()
        dsaForce = 0;
        cellArea = 0.0034 * 0.0034;
        cellMaxVal = 3895;
        cellPressRange = 82200;
    if (finger.type(0) == "dsa") and (finger.type(1) == "dsa") then
        data0 = finger.data(0);
        data1 = finger.data(1);
        for y = 1, #data0.frame[1] do
            for x = 1, #data0.frame do
                dsaForce = dsaForce + data0.frame[x][y] + data1.frame[x][y];
            end
        end
    end   
    return dsaForce * (cellPressRange / cellMaxVal) * cellArea;
end

function dsaGrip()
 print("here1")
    id, forceGoal = cmd.read()
     print("here2")
    mc.force(40)
     print("here3")
    grasping.move(105, 80)
     print("here4")
    mc.move(10, 20, 0)
     print("here5")
    while (mc.aforce() < forceGoal) do
        sleep(5)
        print("here6")
    end
    mc.stop();
    mc.force(mc.aforce());
    grasping.grasp(101, 50, 100);
    --mc.stop()
   

    mc.force(20);
    grasping.move(105, 80);
    grasping.grasp(10, 50, 70)
    print("here6")
    while mc.busy do
         print("here7")
        sleep(10)
       end
    print("here8")
    
    
    mc.force(forceFoal)
    mc.move(105, 50)
    grasping.grasp(80, 50)
    if cmd.online() then
        cmd.send(id, etob(E_SUCCESS))
    end
end

while true do
    if cmd.online() then
        if not pcall(dsaGrip) then
            print("Error occured")
            --print(err.code)
            sleep(100)
        end
    else
        sleep(100)
    end
    --print(getData());
end