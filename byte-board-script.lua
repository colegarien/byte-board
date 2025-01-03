function init(plugin)
    plugin:newCommand{
      id="ByteBoardCopy",
      title="Copy Bytes...",
      group="edit_copy",
      onclick=function()

        local dlg = Dialog()
        dlg:entry{ id="const_name", label="Image Const Name:", text="THE_IMG" }
        dlg:button{ id="confirm", text="Confirm" }
        dlg:button{ id="cancel", text="Cancel" }
        dlg:show()
        local data = dlg.data
        if data.cancel then
          return
        end

        binaryString = ""

        sprite = app.sprite
        finalImgW = sprite.selection.bounds.width
        finalImgH = sprite.selection.bounds.height
        while finalImgW % 8 ~= 0 do
          finalImgW = finalImgW + 1
        end

        minX = sprite.selection.bounds.x - app.image.cel.bounds.x
        maxX = minX + sprite.selection.bounds.width - 1
        minY = sprite.selection.bounds.y - app.image.cel.bounds.y
        maxY = minY + sprite.selection.bounds.height - 1

        heightIterated = 0
        for y=minY,maxY,1 do
          widthIterated = 0
          for x=minX,maxX,1 do
            widthIterated = widthIterated + 1
            if y >= app.image.bounds.y + app.image.bounds.height or x >= app.image.bounds.x + app.image.bounds.width or x < app.image.bounds.x or y < app.image.bounds.y then
              -- trying to read outside of the bounds of the active image
              binaryString = binaryString .. "0"
            else
              pixelValue = Color(app.image:getPixel(x, y))
              if pixelValue.alpha > 0 then
                binaryString = binaryString .. "1"
              else 
                binaryString = binaryString .. "0"
              end
            end
          end
          
          -- pad remaining width with zeros
          widthIterated = finalImgW - widthIterated
          while widthIterated > 0 do
            binaryString = binaryString .. "0"
            widthIterated = widthIterated - 1
          end

          heightIterated = heightIterated + 1
        end
        
        -- pad in extra height with zeros
        heightIterated = finalImgH - heightIterated
        while heightIterated > 0 do
          -- add entire empty rows to image
          for x=1,finalImgW,1 do
            binaryString = binaryString .. "0"
          end
          heightIterated = heightIterated - 1
        end

        wordsPerLine = finalImgW / 8
        currentWord = 0
        output = "// size: ".. finalImgW.." x "..finalImgH.."\nstatic const uint8_t ".. data.const_name .."[] = {\n  "
        for i=1,string.len(binaryString),8 do
            output = output .. "0b" .. string.sub(binaryString, i, i + 7) .. ","
            currentWord = currentWord + 1
            if currentWord >= wordsPerLine then
              currentWord = 0
              output = output .. "\n"
              if i + 7 ~= string.len(binaryString) then
                output = output .. "  "
              end
            end
        end
        output = output .. "};"

        -- copy string to host clipboard
        -- https://community.aseprite.org/t/solved-copy-string-within-aseprite-extension/16344
        local function copy_to_clipboard(str)
          -- returns whether the copy command succeeded
          -- (this function may fail; use pcall)
          local function os_copy(text)
            os_name = string.lower(app.os.name)
            if os_name=="windows" then
              return io.popen('clip','w'):write(text):close()
            elseif os_name=="macos" then
              return io.popen('pbcopy','w'):write(text):close()
            elseif os_name=="linux" then
              return io.popen('xsel --clipboard','w'):write(text):close()
            end
            return nil --failed
          end

          local os_copy_ok = pcall(os_copy,str)
          if not (os_copy_ok) then
            -- autocopy=="manual", or some failure
            -- fallback to print() (can be manually copied with ctrl-c)
            print(str)
          end
        end
        
        -- do it
        copy_to_clipboard(output)
        app.alert("copied to clipboard")
      end
    }
end

