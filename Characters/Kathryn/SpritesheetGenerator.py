from PIL import Image
import os, sys;

spritesheet : Image = Image.new("RGBA", (0, Image.open("costume0.png").size[1]));
i : int = 0;
while os.path.isfile(f"costume{i}.png"):
    costume : Image = Image.open(f"costume{i}.png");
    new_spritesheet : Image = Image.new("RGBA", (spritesheet.size[0] + costume.size[0], spritesheet.size[1]));
    
    new_spritesheet.paste(spritesheet, (0,0))
    new_spritesheet.paste(costume, (spritesheet.size[0], 0));
    
    if len(sys.argv) > 1 and sys.argv[1] == "debug":
        new_spritesheet.show();
    
    spritesheet = new_spritesheet;
    
    if len(sys.argv) > 1 and sys.argv[1] == "debug":
        print(spritesheet.size);
    
    i += 1;

spritesheet.save("spritesheet.png");
