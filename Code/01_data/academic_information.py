#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import os
import pandas as pd
import time
from scholarly import scholarly, ProxyGenerator
from multiprocessing import Process

# Function to get the last checkpoint
def get_last_checkpoint():
    try:
        with open('checkpoint.txt', 'r') as f:
            return int(f.read().strip())
    except FileNotFoundError:
        return 0

# Function to set the checkpoint
def set_checkpoint(position):
    with open('checkpoint.txt', 'w') as f:
        f.write(str(position))

def process_chunk(chunk, chunk_df, start_index):
    chunk_results = []
    countnohits = 0
    ticker = 0
    consecutive_errors = 0

    for one_name in chunk:
        # Setup a new proxy for each iteration
        pg = ProxyGenerator()
        if not pg.FreeProxies() or consecutive_errors > 3:
            if not pg.FreeProxies():
                print("Failed to obtain free proxy.")
                return
        scholarly.use_proxy(pg)

        ticker += 1

        try:
            search_query = scholarly.search_author(one_name)
            author = next(search_query)
            a = scholarly.fill(author, sections=['indices'])
            chunk_results.append(a)
            consecutive_errors = 0

        except StopIteration:
            countnohits += 1
            print(f"{one_name} got no results")
            chunk_results.append({'Name': one_name, 'Error': 'No results'})

        except Exception as e:
            print(f"Error: {e}")
            consecutive_errors += 1
            time.sleep(60 * consecutive_errors)

        if ticker % 10 == 0:
            print(f"Errors: {countnohits}/{ticker}, or {round(countnohits/ticker,2)*100}%")
        set_checkpoint(start_index * len(chunk) + ticker)

    # Save the results of the chunk processing
    chunk_results_df = pd.DataFrame(chunk_results)
    combined_chunk_df = pd.concat([chunk_df.reset_index(drop=True), chunk_results_df.reset_index(drop=True)], axis=1)
    
    # Save to intermediate CSV with chunk index in filename
    combined_chunk_df.to_csv(f'intermediate_results_chunk_{start_index}.csv', index=False)

if __name__ == '__main__':
    file = pd.read_csv('ASU.csv')
    names = file['Name'].tolist()
    chunk_size = 150
    chunks = [names[i:i + chunk_size] for i in range(0, len(names), chunk_size)]
    df_chunks = [file.iloc[i:i + chunk_size] for i in range(0, len(file), chunk_size)]
    start_chunk_index = get_last_checkpoint()

    processes = []
    for index, (chunk, chunk_df) in enumerate(zip(chunks, df_chunks)):
        if index < start_chunk_index:
            continue
        p = Process(target=process_chunk, args=(chunk, chunk_df, index))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()
    intermediate_files = sorted([f for f in os.listdir() if f.startswith('intermediate_results_chunk_')])
    dfs = [pd.read_csv(f) for f in intermediate_files]
    final_results = pd.concat(dfs, ignore_index=True)
    final_results.to_csv('final_combined_results.csv', index=False)

    for f in intermediate_files:
        os.remove(f)
    os.remove('checkpoint.txt')
    final_df = pd.read_csv('final_combined_results.csv')
    print(final_df)

