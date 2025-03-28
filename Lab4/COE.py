from PIL import Image
import numpy as np

# 輸入圖片路徑
image_path = "cat.jpg"
output_coe = "output_color.coe"
output_size = (64, 64)

# 讀取圖片並轉為 RGB 彩色、調整大小
img = Image.open(image_path).convert("RGB").resize(output_size)
pixels = np.array(img)

# 將每個 RGB pixel 轉為 RGB565
def rgb_to_rgb565(r, g, b):
    r5 = (r >> 3) & 0x1F   # 5 bits
    g6 = (g >> 2) & 0x3F   # 6 bits
    b5 = (b >> 3) & 0x1F   # 5 bits
    return (r5 << 11) | (g6 << 5) | b5

flattened = pixels.reshape(-1, 3)
rgb565_list = [rgb_to_rgb565(r, g, b) for r, g, b in flattened]
hex_pixels = [f"{val:04X}" for val in rgb565_list]  # 4碼十六進位

# 輸出為 COE 檔案格式
with open(output_coe, "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    for i, val in enumerate(hex_pixels):
        sep = ";\n" if i == len(hex_pixels) - 1 else ","
        f.write(val + sep)

print(f"✅ 彩色 COE 檔已成功產生：{output_coe}")
