[![Build Status](https://travis-ci.org/ukigumo/Ukigumo-Server.png?branch=master)](https://travis-ci.org/ukigumo/Ukigumo-Server) [![Coverage Status](https://coveralls.io/repos/ukigumo/Ukigumo-Server/badge.png?branch=master)](https://coveralls.io/r/ukigumo/Ukigumo-Server?branch=master)
# NAME

Ukigumo::Server - Testing report storage Server

# SYNOPSIS

    % ukigumo-server

# DESCRIPTION

Ukigumo::Server is testing report storage server. You can use this server for Continious Testing.

<img src="http://gyazo.64p.org/image/dbd98bc15032d97fab081a271541baa2.png" alt="Screen shot">

# INSTALLATION

    % cpanm Ukigumo::Server
    % ukigumo-server
    ukigumo-server starts listen on 0:2828

Or you can use git repo instead of `cpanm Ukigumo::Server` for launching [Ukigumo::Server](http://search.cpan.org/perldoc?Ukigumo::Server).

    % git clone git@github.com:ukigumo/Ukigumo-Server.git .
    # install carton to your system
    % curl -L http://cpanmin.us | perl - Carton
    # And setup the depended modules.
    % carton install
    # Then, run the http server!
    % carton exec perl local/bin/ukigumo-server

# SEE ALSO

[ukigumo-server](http://search.cpan.org/perldoc?ukigumo-server)

# LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokuhirom <tokuhirom@gmail.com>
