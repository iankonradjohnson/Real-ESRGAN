import argparse
import glob
import os
from PIL import Image
from multiprocessing import Pool, cpu_count


def process_image(path, args):
    """Function to process a single image."""
    scale_list = [0.75, 0.5, 1 / 3]
    shortest_edge = 400

    if not os.path.isfile(path):  # skip directories
        return
    print(path)
    basename = os.path.splitext(os.path.basename(path))[0]

    img = Image.open(path)
    width, height = img.size
    for idx, scale in enumerate(scale_list):
        print(f'\t{scale:.2f}')
        rlt = img.resize((int(width * scale), int(height * scale)), resample=Image.LANCZOS)
        rlt.save(os.path.join(args.output, f'{basename}T{idx}.png'))

    # save the smallest image which the shortest edge is 400
    if width < height:
        ratio = height / width
        width = shortest_edge
        height = int(width * ratio)
    else:
        ratio = width / height
        height = shortest_edge
        width = int(height * ratio)
    rlt = img.resize((int(width), int(height)), resample=Image.LANCZOS)
    rlt.save(os.path.join(args.output, f'{basename}T{idx+1}.png'))


def find_files(input_path, recursive):
    """Find files based on the recursive flag."""
    pattern = '**/*' if recursive else '*'
    return sorted(glob.glob(os.path.join(input_path, pattern), recursive=recursive))


def main(args):
    path_list = find_files(args.input, args.recursive)

    # Use a process pool to process images concurrently
    with Pool(processes=cpu_count()) as pool:
        pool.starmap(process_image, [(path, args) for path in path_list])


if __name__ == '__main__':
    """Generate multi-scale versions for GT images with LANCZOS resampling.
    It is now used for DF2K dataset (DIV2K + Flickr 2K)
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, default='datasets/DF2K/DF2K_HR', help='Input folder')
    parser.add_argument('--output', type=str, default='datasets/DF2K/DF2K_multiscale', help='Output folder')
    parser.add_argument('-r', '--recursive', action='store_true', help='Recursively search for files in the input folder')
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)
    main(args)
