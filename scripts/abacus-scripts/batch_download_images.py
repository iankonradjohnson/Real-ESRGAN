import argparse
import numpy as np
import os
import sys
import requests
from tqdm import tqdm
from multiprocessing import Pool, cpu_count

from os import path as osp


def main(args):
    opt = {}
    opt['input_list'] = args.input
    opt['save_folder'] = args.output

    batch_download_images(opt)


def download_image(line, save_folder):
    line = line.strip()
    save_path = os.path.join(save_folder, line.split('/')[-2])
    r = requests.get(line)
    with open(save_path + ".png", 'wb') as f:
        f.write(r.content)


def batch_download_images(opt):
    input_list = opt['input_list']
    save_folder = opt['save_folder']

    if not osp.exists(save_folder):
        os.makedirs(save_folder)
        print(f'mkdir {save_folder} ...')

    with open(input_list, 'r') as f:
        lines = f.readlines()

    with Pool(processes=cpu_count()) as pool:
        list(tqdm(pool.starmap(download_image, [(line, save_folder) for line in lines]),
                  total=len(lines)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, default='', help='Input list')
    parser.add_argument('--output', type=str, default='', help='Output folder')
    args = parser.parse_args()

    main(args)
