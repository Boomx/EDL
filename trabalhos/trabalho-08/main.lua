add = 0
function love.load ()
    width = 800
    height = 600
    centerX = width/2
    centerY = height/2

    angle = 0
    angleMax = 1.5
    angleMin = 0.5

    collideInfo = {false,0}
    ballSpeed = 10
    launched = false
    score = 0

    gameOn = true

    ceil = 0

    love.window.setMode( width, height, {fullscreen=false, vsync=false} )
    
    shooter = generateShooter()
    gaugeWay = true

    ball = nill
    BallModel = {x=0,y=0,velX = 0, velY = 0, radius = 10, halfheight = 10, halfwidth = 10}

        
    function BallModel.drawBall()
        love.graphics.circle("fill",ball.x,ball.y,ball.radius)
    end

    function BallModel.move(dt)
        BallModel.x = BallModel.x + BallModel.velX * dt * ballSpeed
        BallModel.y = BallModel.y + BallModel.velY * dt * ballSpeed
    end
    
    bars = {}
    movingBar = generateMovingBar(200,200,100)
    createBars() 
end

function generateShooter()
    local val = 0
    local x = 20
    local y = 20
    local raio = 60
    return {
        getX = function() return x end, 
        setX = function(val) x = val end,
        getY = function() return y end, 
        setY = function(val) y = val end,
        radius = function() return raio end
    }
end

function generateMovingBar(x,y,vel)
    local me; 
    local xLimits = {200,500}
    local yLimits = {100,400}
    local height = 20
    local width = 100
    local halfwidth = width/4
    local halfheight = height/4
    local enabled = true
    local setHorizontal = function(horizontal)
        if((horizontal and height > width) or (not horizontal and height < width)) then
                local tempH = height
                height =  width
                width = tempH
        end
    end
    me = {
        xLimits = xLimits
        , yLimits = yLimits
        , height = height
        , width = width
        , halfwidth = halfwidth
        , enabled = enabled
        , move = function(dx,dy)
            -- Trabalho-08: x e y são usados como closure, guardando o valor dado por argumento e usando quando necessário
                x = x + dx
                y = y + dy
                if (x > xLimits[2]) then x = xLimits[2] end
                if (y > yLimits[2]) then y = yLimits[2] end
                if (x < xLimits[1]) then x = xLimits[1] end
                if (y < yLimits[1]) then y = yLimits[1] end
            end
        , get = function ()
                return x, y, height, width, height/4, width/4
        end
        -- Trabalho-08: co é uma coroutine que define o comportamento da barra que se movimenta
        , co = coroutine.create( function(dt)
                    while true do
                        if(x < xLimits[2] and y == yLimits[1]) then
                            setHorizontal(true)
                            me.move(vel*dt,0)
                        elseif(x > xLimits[1] and y == yLimits[2]) then
                            setHorizontal(true)
                            me.move(-vel*dt,0)
                        elseif(y <= yLimits[2] and x == xLimits[1]) then
                            setHorizontal(false)
                            me.move(0,-vel*dt)
                        else 
                            setHorizontal(false)
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

function createBars()
    local barMinW = 20
    local barMaxW = 200
    local barH = 20
    local barN = 3 + math.floor(math.random() * 7)
    for i=1, barN do
        local newBarW = 10 + (math.random() * (barMaxW - barMinW))
        local newBar = {
            x = 0 + math.random() * (width - barMaxW)
            , y =  10 + math.random() * height-barH - 100
            , height = barH
            , width = newBarW
            , halfwidth = newBarW/4
            , halfheight = barH /4
            , enabled = true}
        table.insert(bars,newBar)
    end
end

function love.update (dt)
    if (gameOn) then
        coroutine.resume(movingBar.co,dt)
        gaugeAngle(dt)
        if (ball) then
            ball.move(dt)
            collideInfo[1] = collideBorders()
            collideBarsAndScore()
        end
    end
end

function love.draw ()
    local x,y,barH,barW = movingBar.get()

    love.graphics.rectangle('fill', x,y, barW, barH);

    shooter.setX(centerX + (shooter.radius() * math.sin(angle * math.pi)))
    shooter.setY(height + (shooter.radius() * math.cos(angle * math.pi)))
    love.graphics.circle("fill",shooter.getX(),shooter.getY(),10)

    if(ball) then
        ball.drawBall()
    end
    for i=1, table.getn(bars) do
        bar = bars[i]
        if(bar.enabled) then
            love.graphics.rectangle("line",bar.x,bar.y,bar.width,bar.height)
        end
    end

    love.graphics.printf("Voce fez " .. score .. " pontos", width - 200,height-100,200,"left")

    if(not gameOn) then 
        love.graphics.printf("GAME OVER", centerX-100,centerY,400,"left")
        love.graphics.printf("VOCÊ FEZ " .. score .. " PONTOS", centerX-100,centerY + 50,400,"left")
        love.graphics.printf("APERTE R PARA RECOMEÇAR", centerX-100,centerY + 100,400,"left")
    end

    logMe()
end

function invertMovement(axis)
    if (axis == "y") then
        ball.velY = - ball.velY * 1.001
    elseif(axis == "x") then
        ball.velX = - ball.velX * 1.001
    end
end

function collideBarsAndScore()
    local myScore = 0
    for i = 1, table.getn(bars) do
        bar = bars[i]
        if (bar.enabled) then
            if (collidingForTwoRectangles(bar.x,bar.y,bar.height,bar.width,bar.halfheight,bar.halfwidth)) then
                collideInfo[2] =  collideInfo[2] + 1
                bar.enabled = false
            end
        else
            myScore = myScore + 1
        end
    end

    if (collidingForTwoRectangles(movingBar.get())) then
        collideInfo[2] =  collideInfo[2] + 1
    end
    score = myScore * 10;
end
        
function gaugeAngle(dt)
    angleVel = 1
    if(gaugeWay) then
        angle = angle + (dt * angleVel)
    else
        angle = angle - (dt * angleVel)
    end

    if(angle > angleMax) then
        angle = angleMax
        gaugeWay = false
    elseif (angle < angleMin) then
        angle = angleMin
        gaugeWay = true
    end
end


function love.keypressed(key)
    if(gameOn) then
        if key == 'a' then
            ball = BallModel
            ball.x = shooter.getX() 
            ball.y = shooter.getY()
            ball.velX = shooter.getX()  - centerX
            ball.velY = shooter.getY() - height 
        end
    else
        if (key == 'r') then 
            love.load()
        end
    end
end

function collidingForTwoRectangles(x,y, height, width, halfheight,halfwidth)   
    local leftrightoverlap = math.min(y+height,ball.y+ball.halfheight)-math.max(y,ball.y-ball.halfheight)
    local bottomtopoverlap = math.min(x+width,ball.x+ball.halfwidth)-math.max(x,ball.x-ball.halfwidth)
    if (leftrightoverlap>0 and bottomtopoverlap>0) then
        if(leftrightoverlap>bottomtopoverlap) then 
            invertMovement("x")
        else
            invertMovement("y")
        end
        return true
    end
    return false
end

function collideBorders()
    if((ball.x + ball.radius > width) or (ball.x - ball.radius < 0)) then
        invertMovement("x")
        return true
    elseif((ball.y - ball.radius < 0)) then
        invertMovement("y")
        return true
    elseif ((ball.y + ball.radius > height)) then
        gameOn = false
    end
    return false
end

function logMe()
    local x,y = movingBar.get()
    logs = {
        {"x1: " .. x}
        , {"y1: " .. y}
        , {"add: " .. boolToString(add)}
        -- , {"OBJ X: " .. globalOBJ.x}
        -- , {"OBJ Y: " .. globalOBJ.y}
    }
    log2(logs)
end

function boolToString(boolean)
    if(boolean) then
        return  "true"
    else
        return "false"
    end
end