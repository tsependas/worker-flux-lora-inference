import os
# 🧠 Prevent CUDA memory fragmentation
os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"

import runpod
import torch
from diffusers import FluxPipeline
import time

# Initialize models
def initialize_models():
    model_path = "/runpod-volume/flux1-dev"

    # Load FLUX pipeline
    pipe = FluxPipeline.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        use_safetensors=True
    )

    # 🧠 Enable memory-efficient attention if xformers is installed
    try:
        pipe.enable_xformers_memory_efficient_attention()
        print("✅ Enabled xformers memory-efficient attention.")
    except Exception as e:
        print(f"⚠️ Could not enable xformers attention: {e}")

    return pipe

# Load model at startup
pipe = initialize_models()

# Image generation logic
def generate_image(prompt, negative_prompt="", num_inference_steps=28):
    torch.cuda.empty_cache()  # Clear unused memory

    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=num_inference_steps
    ).images[0]

    return image

# RunPod serverless handler
def handler(event):
    print("🚀 Worker start")
    input = event['input']

    prompt = input.get('prompt')
    negative_prompt = input.get('negative_prompt', '')
    num_inference_steps = input.get('num_inference_steps', 28)

    print(f"📥 Prompt: {prompt}")

    try:
        result = generate_image(prompt, negative_prompt, num_inference_steps)
        return {
            "status": "success",
            "result": result
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

# Run as serverless function
if __name__ == '__main__':
    runpod.serverless.start({'handler': handler})
