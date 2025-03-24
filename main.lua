function love.load()
    player={x=64,y=64,r=16}
    walls={{8, 8, 256, 8}, {256, 8, 256, 256}, {256, 256, 8, 256}, {8, 256, 8, 8},
            {128-16, 128-16, 128+16, 128-16}, {128+16, 128-16, 128+16, 128+16}, {128+16, 128+16, 128-16, 128+16}, {128-16, 128+16, 128-16, 128-16}}
end

function love.update(dt)
    local dx, dy = 0, 0
    local speed = 2

    if love.keyboard.isDown("up") then
        dy = dy - speed
    end
    if love.keyboard.isDown("down") then
        dy = dy + speed
    end
    if love.keyboard.isDown("left") then
        dx = dx - speed
    end
    if love.keyboard.isDown("right") then
        dx = dx + speed
    end

    --normalize movement
    if dx~=0 and dy~=0 then
        local normalized = 1 / math.sqrt(1)
        dx, dy = dx * normalized, dy * normalized
    end

    while dx~=0 or dy~=0 do
        local tiny=1e-10

        local dxIncrement, dyIncrement = math.min(player.r-tiny, dx), math.min(player.r-tiny, dy)
        if dx<0 then
            dxIncrement = math.max(-player.r+tiny, dx)
        end
        if dy<0 then
            dyIncrement = math.max(-player.r+tiny, dy)
        end

        player.x, player.y = player.x + dxIncrement, player.y + dyIncrement
        player.x, player.y = wallCollision(player.x, player.y, player.r, walls)

        dx, dy = dx - dxIncrement, dy - dyIncrement
    end

end

function love.draw()
    love.graphics.circle("fill", player.x, player.y, player.r)
    for _, wall in pairs(walls) do
        love.graphics.line(wall[1], wall[2], wall[3], wall[4])
    end
end

function wallCollision(x, y, r, walls)
    local loopOverWalls = true

    while loopOverWalls do
        loopOverWalls = false
        for _, wall in ipairs(walls) do
            local x1,y1=pushCircleOutOfLine(x, y, r, wall[1], wall[2], wall[3], wall[4])
            if x~=x1 or y~=y1 then
                x, y = x1, y1
                collided = true
            end
        end
    end

    return x, y
end

function pushCircleOutOfLine(cx, cy, radius, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local lx, ly = cx - x1, cy - y1

    local t = lx * dx + ly * dy -- Get the dot product (How closely the direction of two vectors align)
    t = t / (dx * dx + dy * dy) -- Divide by the length of the line squared (Notice how the parentheses are the formula to calculate distance, minus the final step where we get the square root of the result. This means the result of the parentheses is equal to the length of the line squared)
    -- The reason we normalize t as a fraction of the line length is so that it can be used to multiply both dx and dy to get the respective position in each direction.

    t = math.max(0, math.min(1, t)) -- Clamp between 0 and 1 to ensure nearest point is on the line segment

    -- Convert t to x and y coordinates to find the closest point on the line to the circle's center.
    local nx = x1 + t * dx
    local ny = y1 + t * dy

    -- Compute the distance between the circle's center and the closest point on the line
    local dist = math.sqrt((cx - nx) * (cx - nx) + (cy - ny) * (cy - ny))

    -- If the closest point is inside the radius, push outward
    if dist < radius then
        local push = radius - dist -- This is how far the circle must be pushed out of the line to resolve the collision
        
        local normX = (cx - nx) / dist 
        local normY = (cy - ny) / dist -- Normalize the vector from the closest point to the circle to have a magnitude of 1 so that the direction is stored and we can apply the desired push amount to it later

        -- Multipy the normalized x and y vectors by the push amount and add it to the circle's x and y components to move the circle
        local newCx = cx + normX * push
        local newCy = cy + normY * push

        return newCx, newCy -- Return the new calculated values
    end

    return cx, cy -- Return the original coordinates if the circle is not overlapping with the line
end