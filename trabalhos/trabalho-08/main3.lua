add = 0

function generateMovingBar(x,y,vel)
    local me; 
    local xLimits = {200,500}
    local yLimits = {200,500}
    local height = 20
    local width = 100
    local halfwidth = width/4
    local halfheight = height/4
    local enabled = true
    me = {
        xLimits = xLimits
        , yLimits = yLimits
        , height = height
        , width = width
        , halfwidth = halfwidth
        , enabled = enabled
        , move = function(dx,dy)
                x = x + dx
                y = y + dy
                if (x > xLimits[2]) then x = xLimits[2] end
                if (y > yLimits[2]) then y = yLimits[2] end
                if (x < xLimits[1]) then x = xLimits[1] end
                if (y < yLimits[1]) then y = yLimits[1] end
            end
        , get = function ()
                return x, y
        end
        , co = coroutine.create( function(dt)
                    while true do
                        add = add + 1
                        if(x <= xLimits[2] and y == yLimits[1]) then
                            me.move(vel*dt,0)
                        elseif(x >= xLimits[1] and y == yLimits[2]) then
                            me.move(-vel*dt,0)
                        elseif(y <= yLimits[2] and x == xLimits[1]) then
                            me.move(0,-vel*dt)
                        else 
                            me.move(0,vel*dt)
                        end
                        dt = coroutine.yield()
                    end
                end),
    }
    return me
end

function log2(args)
    for i=1, table.getn(args) do
        love.graphics.printf(args[i], width-200,height-(i*30),200,"left")
    end
end

function love.load()
    width = 800
    height = 600
    movingBar = generateMovingBar(200,200,100)
end

function love.update(dt)
    p1 = coroutine.status(movingBar.co)
    coroutine.resume(movingBar.co,dt)
    p2 = coroutine.status(movingBar.co)
end

function love.draw()
    local x,y = movingBar.get()

    love.graphics.rectangle('fill', x,y, 20,20);

    logMe()
end

function logMe()
    local x,y = movingBar.get()
    logs = {
        {"x: " .. x}
        , {"y: " .. y}
        , {"add: " .. add}
        -- ,{"p1: " .. p1}
        -- ,{"p2: " .. p2}
        -- , {"OBJ X: " .. globalOBJ.x}
        -- , {"OBJ X: " .. globalOBJ.x}
        -- , {"OBJ Y: " .. globalOBJ.y}
    }
    log2(logs)
end

-- function generateMovingBar (x,y,vx)
--     local me; 
--     local xLimits = {200,500}
--     local yLimits = {200,500}
--     local height = 20
--     local width = 100
--     local halfwidth = width/4
--     local halfheight = height/4
    -- local enabled = true
    -- me = {
    --     xLimits = xLimits
    --     , yLimits = yLimits
    --     , height = height
    --     , width = width
    --     , halfwidth = halfwidth
    --     , enabled = enabled
    --     , move = function(dx,dy)
    --             x = x + dx
--                 y = y + dy
--                 if (x > xLimits[2]) then x = xLimits[2] end
--                 if (y > yLimits[2]) then y = yLimits[2] end
--                 if (x < xLimits[1]) then x = xLimits[1] end
--                 if (y < yLimits[1]) then y = yLimits[1] end
--                 -- return x,y
--             end,
--         get = function ()
--              return x, y
--         end,
--         co = coroutine.create(function (dt)
--             while true do
--                 add = add + 1
--                 me.move( vx*dt, 0)
--                 dt = coroutine.yield()
--             end
--         end),
--     }
--     return me
-- end

-- function love.load()
--     movingBar = generateMovingBar(0,  290,  100)
--     width = 800
--     height = 600
-- end
-- function love.update (dt)
--     coroutine.resume(movingBar.co, dt)
-- end

-- function love.draw ()
--     local x,y = movingBar.get()
--     love.graphics.rectangle('fill', x,y, 20,20)

--     logMe()
-- end