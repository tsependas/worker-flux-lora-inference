# download_flux.py
from diffusers import FluxPipeline
import torch

def download_flux_model(save_dir: str = "flux1-dev"):
    print(f"📥 Downloading FLUX.1-dev to '{save_dir}' ...")
    pipe = FluxPipeline.from_pretrained(
        "black-forest-labs/FLUX.1-dev",
        torch_dtype=torch.bfloat16  # Or torch.float16 if needed
    )
    pipe.save_pretrained(save_dir)
    print("✅ Download complete.")

if __name__ == "__main__":
    download_flux_model()