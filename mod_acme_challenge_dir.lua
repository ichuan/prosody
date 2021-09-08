module:depends("http");

local fileserver = require"net.http.files";

module:provides("http", {
  default_path = "/.well-known/acme-challenge";
  route = {
    ["GET /*"] = fileserver.serve({
       path = module:get_option_string("http_files_dir", "/tmp").."/.well-known/acme-challenge";
       directory_index = false;
    })
  };
});
