[![Build Status](https://travis-ci.org/ukigumo/Ukigumo-Server.svg?branch=master)](https://travis-ci.org/ukigumo/Ukigumo-Server) [![Coverage Status](https://img.shields.io/coveralls/ukigumo/Ukigumo-Server/master.svg?style=flat)](https://coveralls.io/r/ukigumo/Ukigumo-Server?branch=master)
# NAME

Ukigumo::Server - Testing report storage Server

# SYNOPSIS

    % ukigumo-server

# DESCRIPTION

Ukigumo::Server is testing report storage server. You can use this server for Continious Testing.

<div>
    <img src="https://dl.dropboxusercontent.com/u/14832699/Ukigumo-Server-Top.png" alt="Screen shot">
</div>

# INSTALLATION

    % cpanm Ukigumo::Server
    % ukigumo-server
    ukigumo-server starts listen on 0:2828

Or you can use git repo instead of `cpanm Ukigumo::Server` for launching [Ukigumo::Server](https://metacpan.org/pod/Ukigumo::Server).

    % git clone git@github.com:ukigumo/Ukigumo-Server.git .
    # install carton to your system
    % curl -L http://cpanmin.us | perl - Carton
    # And setup the depended modules.
    % carton install
    # Then, run the http server!
    % carton exec perl local/bin/ukigumo-server

# SEE ALSO

[ukigumo-server](https://metacpan.org/pod/ukigumo-server)

# LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokuhirom <tokuhirom@gmail.com>
