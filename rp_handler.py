import runpod
import torch
from diffusers import FluxPipeline
import time

# Initialize models
def initialize_models():
    # Initialize Flux dev 1 model from local workspace
    model_path = "/workspace/flux1-dev"
    pipe = FluxPipeline.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        device_map="balanced"
    )
    return pipe

# Initialize model at startup
pipe = initialize_models()

def generate_image(prompt, negative_prompt="", num_inference_steps=50):
    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=num_inference_steps
    ).images[0]
    return image

def handler(event):
    print(f"Worker Start")
    input = event['input']
    
    prompt = input.get('prompt')
    negative_prompt = input.get('negative_prompt', '')
    num_inference_steps = input.get('num_inference_steps', 28)
    
    print(f"Received prompt: {prompt}")
    
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

if __name__ == '__main__':
    runpod.serverless.start({'handler': handler})
