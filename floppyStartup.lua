if not turtle then
    -- If computer is rebooting, give it server code
    fs.delete("server")
    shell.run("pastebin get ywNMCRGP server")
    shell.run("server")
else
    -- If turtle is rebooting, give it turtle code
    fs.delete("turtle")
    shell.run("pastebin get 3Bu3TPUJ turtle")
    shell.run("turtle")
end