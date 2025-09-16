
import os
import glob
import subprocess
import matplotlib.pyplot as plt

# Directory containing spades_results
spades_dir = 'spades_results'

# Find all GFA files recursively (including assembly_graph_after_simplification.gfa)
gfa_files = glob.glob(os.path.join(spades_dir, '**', '*after_simplification.gfa'), recursive=True)

contigs_list = []
dead_ends_list = []
bubbles_list = []
labels = []

def parse_gfastats_output(output):
	"""
	Parse gfastats output to extract all relevant stats as a dictionary.
	Returns a dict with keys for each stat found.
	"""
	stats = {}
	for line in output.splitlines():
		line = line.strip()
		if not line or line.startswith('+++'):
			continue
		# Remove comments
		if '#' in line:
			line = line[2:]
		if ':' in line:
			key, value = line.split(':', 1)
			key = key.strip().lower().replace(' ', '_').replace('%','pct')
			value = value.strip()
			# Try to convert to int or float if possible
			if value.lower() == 'nan':
				stats[key] = None
			else:
				try:
					if '.' in value:
						stats[key] = float(value)
					else:
						stats[key] = int(value)
				except Exception:
					stats[key] = value
	return stats

contigs_list = []
dead_ends_list = []
bubbles_list = []
labels = []
all_stats = []

import os
import glob
import subprocess
import matplotlib.pyplot as plt

# Directory containing spades_results
spades_dir = 'spades_results'

# Find all GFA files recursively (including assembly_graph_after_simplification.gfa)
gfa_files = glob.glob(os.path.join(spades_dir, '**', '*after_simplification.gfa'), recursive=True)

# Main processing loop
for gfa_file in gfa_files:
	try:
		result = subprocess.run(['gfastats', gfa_file], capture_output=True, text=True, check=True)
		graph_stats = parse_gfastats_output(result.stdout)
		scaffolds = os.path.join(os.path.dirname(gfa_file), 'scaffolds.fasta')
		result = subprocess.run(['gfastats', scaffolds], capture_output=True, text=True, check=True)
		scaff_stats = parse_gfastats_output(result.stdout)
		# If any value of graph_stats is 0 or None, update from scaff_stats
		for key in graph_stats:
			if (graph_stats[key] is None or graph_stats[key] == 0) and key in scaff_stats and scaff_stats[key] not in (None, 0):
				graph_stats[key] = scaff_stats[key]

		contigs = graph_stats.get('contigs')
		dead_ends = graph_stats.get('dead_ends')
		bubbles = graph_stats.get('bubbles')
		all_stats.append(graph_stats)

		if contigs is not None and dead_ends is not None and bubbles is not None:
			contigs_list.append(contigs)
			dead_ends_list.append(dead_ends)
			bubbles_list.append(bubbles)
			labels.append(os.path.dirname(gfa_file).split('/')[-1])
	except Exception as e:
		print(f"Error processing {gfa_file}: {e}")

# Scatter plot: contigs vs dead ends
plt.figure(figsize=(8,6))
plt.scatter(contigs_list, dead_ends_list)
for i, label in enumerate(labels):
	plt.annotate(label, (contigs_list[i], dead_ends_list[i]), fontsize=8)
plt.xlabel('Number of Contigs')
plt.ylabel('Number of Dead Ends')
plt.title('Contigs vs Dead Ends')
plt.tight_layout()
plt.savefig('contigs_vs_dead_ends.png')
plt.close()

# Scatter plot: contigs vs bubbles
plt.figure(figsize=(8,6))
plt.scatter(contigs_list, bubbles_list)
for i, label in enumerate(labels):
	plt.annotate(label, (contigs_list[i], bubbles_list[i]), fontsize=8)
plt.xlabel('Number of Contigs')
plt.ylabel('Number of Bubbles')
plt.title('Contigs vs Bubbles')
plt.tight_layout()
plt.savefig('contigs_vs_bubbles.png')
plt.close()
# output all the stats as a table. 
import pandas as pd
df = pd.DataFrame(all_stats)
df.to_csv('assembly_stats.csv', index=False)
