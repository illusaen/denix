{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.desktop.llama ];
  den.aspects.desktop.llama.nixos =
    { pkgs, ... }:
    let
      llama-cpp = pkgs.llama-cpp.override { cudaSupport = true; };
    in
    {
      environment.systemPackages = [ llama-cpp ];
      services.llama-cpp = {
        enable = true;
        package = llama-cpp;
        # Takes care of downloading if model not present
        modelsPreset = {
          "Qwen3.5-9B" = {
            hf-repo = "unsloth/Qwen3.5-9B-GGUF";
            hf-file = "Qwen3.5-9B-UD-Q6_K_XL.gguf";
            alias = "unsloth/Qwen3.5-9B";
            temp = "1.0";
            top-p = "0.95";
            top-k = "20";
            min_p = "0.0";
            presence_penalty = "1.5";
            repetition_penalty = "1.0";
          };
        };
      };
    };
}
