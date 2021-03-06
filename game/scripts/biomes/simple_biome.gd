extends Biome

# Copyright (c) 2019 Péter Magyar
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

func _generate_chunk(chunk: VoxelChunk, spawn_mobs: bool) -> void:
#	var chunk : VoxelChunk = chunk.get_chunk()
	
	generate_terrarin(chunk, spawn_mobs)

func generate_terrarin(chunk : VoxelChunk, spawn_mobs: bool) -> void:
#	chunk.create(int(chunk.size_x) + 1, int(chunk.size_y) + 1, int(chunk.size_z) + 1)
	chunk.set_size(int(chunk.size_x), int(chunk.size_y), int(chunk.size_z), 0, 1)
	
	var noise : OpenSimplexNoise = OpenSimplexNoise.new()
	noise.seed = 10 * current_seed
	noise.octaves = 4
	noise.period = 180.0
	noise.persistence = 0.8
	
	var terr_noise : OpenSimplexNoise = OpenSimplexNoise.new()
	terr_noise.seed = 10 * 321 + 112 * current_seed
	terr_noise.octaves = 4
	terr_noise.period = 20.0
	terr_noise.persistence = 0.9
	
	var det_noise : OpenSimplexNoise = OpenSimplexNoise.new()
	det_noise.seed = 10 * 3231 + 112 * current_seed
	det_noise.octaves = 6
	det_noise.period = 10.0
	det_noise.persistence = 0.3
	
	for x in range(0, chunk.size_x + 1):
		for z in range(0, chunk.size_z + 1):
			var val : float = noise.get_noise_2d(x + (chunk.position_x * chunk.size_x), z + (chunk.position_z * chunk.size_z))
			val *= val
			val *= 100
			val += 2
			
			var tv : float = terr_noise.get_noise_2d(x + (chunk.position_x * chunk.size_x), z + (chunk.position_z * chunk.size_z))
			tv *= tv * tv * tv
			val += tv * 2
			
			var dval : float = noise.get_noise_2d(x + (chunk.position_x * chunk.size_x), z + (chunk.position_z * chunk.size_z))
			
			val += dval * 6
			
			var v : int = (int(val))
			
			v -= chunk.position_y * (chunk.size_y)

			if v > chunk.size_y + 1:
				v = chunk.size_y + 1

			for y in range(0, v):
				seed(x + (chunk.position_x * chunk.size_x) + z + (chunk.position_z * chunk.size_z) + y + (chunk.position_y * chunk.size_y))
				
				if v < 2:
					chunk.set_voxel(1, x, y, z, VoxelChunk.DEFAULT_CHANNEL_TYPE)
				elif v == 2:
					chunk.set_voxel(3, x, y, z, VoxelChunk.DEFAULT_CHANNEL_TYPE)
				else:
					chunk.set_voxel(2, x, y, z, VoxelChunk.DEFAULT_CHANNEL_TYPE)

				var val2 : float = (val - int(val)) * 3.0
				val2 = int(val2)
				val2 /= 3.0
				
				chunk.set_voxel(int(255.0 * val2), x, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
#				chunk.set_voxel(int(255.0 * (val - int(val)) / 180.0) * 180, x, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
#				chunk.set_voxel(int(255.0 * (val - int(val))), x, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)

#	box_blur(chunk)

#	chunk.build()

	if not Engine.editor_hint and chunk.position_y == 0 and spawn_mobs:
		Entities.spawn_mob(1, randi() % 3, Vector3(chunk.position_x * chunk.size_x * chunk.voxel_scale - chunk.size_x / 2,\
							(chunk.position_y + 1) * chunk.size_y * chunk.voxel_scale, \
							chunk.position_z * chunk.size_z * chunk.voxel_scale - chunk.size_z / 2))

func box_blur(chunk : VoxelChunk):
	for x in range(0, chunk.size_x):
		for z in range(0, chunk.size_z):
			for y in range(0, chunk.size_z):
				
				var avg : float = 0
				
				avg += chunk.get_voxel(x, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x + 1, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x, y, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x + 1, y, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x, y + 1, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x + 1, y + 1, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x, y + 1, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				avg += chunk.get_voxel(x + 1, y + 1, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				
				avg /= 8.0
				var aavg: int = int(avg)
				
				chunk.set_voxel(aavg, x, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x + 1, y, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x, y, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x + 1, y, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x, y + 1, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x + 1, y + 1, z, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x, y + 1, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
				chunk.set_voxel(aavg, x + 1, y + 1, z + 1, VoxelChunk.DEFAULT_CHANNEL_ISOLEVEL)
