{config, ...}: {
    home.activation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    function add_link() {
        if [ -e "$2" && 
    }
    '';
}
