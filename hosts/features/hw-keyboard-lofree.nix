{ ... }:
{
  # Fix lofree keyboard FN keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # Keyboard remapping
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [
          # Empty list means "apply to all keyboards"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps
          )

          (defalias
            escctrl (tap-hold 150 150 esc lctrl)
          )

          (deflayer base
            @escctrl
          )
        '';
      };
    };
  };
}
