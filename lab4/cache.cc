/**
 * ECE 430.322: Computer Organization
 * Lab 4: Cache Simulation
 */

#include "cache.h"
#include <iostream>
#include <string>
#include <cmath>

#include <bitset>

 /**
  * This allocates an "assoc" number of cache entries per a set
  * @param assoc - number of cache entries in a set
  */
cache_set_c::cache_set_c(int assoc) {
	m_entry = new cache_entry_c[assoc];
	m_assoc = assoc;
	order = new int[assoc];
	for (int i = 0; i < assoc; i++) {
		order[i] = i;
	}
}

// cache_set_c destructor
cache_set_c::~cache_set_c() {
	delete[] m_entry;
	delete[] order;
}

/**
 * This constructor initializes a cache structure based on the cache parameters.
 * @param name - cache name; use any name you want
 * @param num_sets - number of sets in a cache
 * @param assoc - number of cache entries in a set
 * @param line_size - cache block (line) size in bytes
 */
cache_c::cache_c(std::string name, int num_sets, int assoc, int line_size) {
	m_name = name;
	m_num_sets = num_sets;
	m_line_size = line_size;

	m_set = new cache_set_c * [m_num_sets];

	for (int ii = 0; ii < m_num_sets; ++ii) {
		m_set[ii] = new cache_set_c(assoc);

		// initialize tag/valid/dirty bits
		for (int jj = 0; jj < assoc; ++jj) {
			m_set[ii]->m_entry[jj].m_valid = false;
			m_set[ii]->m_entry[jj].m_dirty = false;
			m_set[ii]->m_entry[jj].m_tag = 0;
		}
	}

	// initialize stats
	m_num_accesses = 0;
	m_num_hits = 0;
	m_num_misses = 0;
	m_num_writes = 0;
	m_num_writebacks = 0;
}

// cache_c destructor
cache_c::~cache_c() {
	for (int ii = 0; ii < m_num_sets; ++ii) { delete m_set[ii]; }
	delete[] m_set;
}

/**
 * This function looks up in the cache for a memory reference.
 * This needs to update all the necessary meta-data (e.g., tag/valid/dirty)
 * and the cache statistics, depending on a cache hit or a miss.
 * @param address - memory address
 * @param access_type - read (0), write (1), or instruction fetch (2)
 */
void cache_c::access(addr_t address, int access_type) {
	////////////////////////////////////////////////////////////////////
	// TODO: Write the code to implement this function

	std::bitset<64> add_2(address);
	std::string s = add_2.to_string();

	int idx_size = log2(m_num_sets);						//8
	int bog_size = log2(m_line_size);						//6
	int tag_size = 64 - idx_size - bog_size;				//50

	addr_t tag = 0;
	for (int i = 0; i < tag_size; i++) {
		if (s[i] == '1') {
			tag = pow(2, (tag_size - 1 - i)) + tag;
		}
	}
	int idx = 0;
	for (int i = 0; i < idx_size; i++) {
		if (s[tag_size + i] == '1') {
			idx = pow(2, (idx_size - 1 - i)) + idx;
		}
	}

	bool hit = false;
	bool evict_invalid = false;

	if (access_type == 0 || access_type == 2) {
		for (int i = 0; i < m_set[idx]->m_assoc; i++) {
			if ((m_set[idx]->m_entry[i].m_tag == tag) && (m_set[idx]->m_entry[i].m_valid == true)) {
				hit = true;
				m_num_hits++;
				for (int k = m_set[idx]->m_assoc - 1; k >= 0; k--) {
					if (m_set[idx]->order[k] == i) {
						for (int j = k - 1; j >= 0; j--) {
							m_set[idx]->order[j + 1] = m_set[idx]->order[j];
						}
						m_set[idx]->order[0] = i;
						break;
					}
				}
				break;
			}
		}
		if (!hit) {
			m_num_misses++;
			for (int i = 0; i < m_set[idx]->m_assoc; i++) {
				if (m_set[idx]->m_entry[i].m_valid == false) {		//evict i th
					if (m_set[idx]->m_entry[i].m_dirty == true) {
						m_num_writebacks++;
					}
					m_set[idx]->m_entry[i].m_tag = tag;
					m_set[idx]->m_entry[i].m_valid = true;
					m_set[idx]->m_entry[i].m_dirty = false;

					for (int k = m_set[idx]->m_assoc - 1; k >= 0; k--) {
						if (m_set[idx]->order[k] == i) {
							for (int j = k - 1; j >= 0; j--) {
								m_set[idx]->order[j + 1] = m_set[idx]->order[j];
							}
							m_set[idx]->order[0] = i;
							break;
						}
					}
					evict_invalid = true;
					break;
				}
			}
			if (!evict_invalid) {
				int lru = m_set[idx]->order[m_set[idx]->m_assoc - 1];

				if (m_set[idx]->m_entry[lru].m_dirty == true) {
					m_num_writebacks++;
				}
				m_set[idx]->m_entry[lru].m_tag = tag;
				m_set[idx]->m_entry[lru].m_valid = true;
				m_set[idx]->m_entry[lru].m_dirty = false;

				for (int j = m_set[idx]->m_assoc - 2; j >= 0; j--) {
					m_set[idx]->order[j + 1] = m_set[idx]->order[j];
				}
				m_set[idx]->order[0] = lru;
			}
		}
		m_num_accesses++;
	}
	else if (access_type == 1) {
		for (int i = 0; i < m_set[idx]->m_assoc; i++) {
			if ((m_set[idx]->m_entry[i].m_tag == tag) && (m_set[idx]->m_entry[i].m_valid == true)) {
				hit = true;
				m_num_hits++;
				m_set[idx]->m_entry[i].m_tag = tag;
				m_set[idx]->m_entry[i].m_valid = true;
				m_set[idx]->m_entry[i].m_dirty = true;
				m_num_writes++;

				for (int k = m_set[idx]->m_assoc - 1; k >= 0; k--) {
					if (m_set[idx]->order[k] == i) {
						for (int j = k - 1; j >= 0; j--) {
							m_set[idx]->order[j + 1] = m_set[idx]->order[j];
						}
						m_set[idx]->order[0] = i;
						break;
					}
				}
				break;
			}
		}
		if (!hit) {
			m_num_misses++;
			for (int i = 0; i < m_set[idx]->m_assoc; i++) {
				if (m_set[idx]->m_entry[i].m_valid == false) {
					if (m_set[idx]->m_entry[i].m_dirty == true) {
						m_num_writebacks++;
					}
					m_set[idx]->m_entry[i].m_tag = tag;
					m_set[idx]->m_entry[i].m_valid = true;
					m_set[idx]->m_entry[i].m_dirty = true;
					m_num_writes++;

					for (int k = m_set[idx]->m_assoc - 1; k >= 0; k--) {
						if (m_set[idx]->order[k] == i) {
							for (int j = k - 1; j >= 0; j--) {
								m_set[idx]->order[j + 1] = m_set[idx]->order[j];
							}
							m_set[idx]->order[0] = i;
							break;
						}
					}
					evict_invalid = true;
					break;
				}
			}
			if (!evict_invalid) {
				int lru = m_set[idx]->order[m_set[idx]->m_assoc - 1];

				if (m_set[idx]->m_entry[lru].m_dirty == true) {
					m_num_writebacks++;
				}
				m_set[idx]->m_entry[lru].m_tag = tag;
				m_set[idx]->m_entry[lru].m_valid = true;
				m_set[idx]->m_entry[lru].m_dirty = true;
				m_num_writes++;

				for (int j = m_set[idx]->m_assoc - 2; j >= 0; j--) {
					m_set[idx]->order[j + 1] = m_set[idx]->order[j];
				}
				m_set[idx]->order[0] = lru;
			}
		}
		m_num_accesses++;
	}
	else {
		std::cout << "INVALID access_type" << std::endl;
		return;
	}
	////////////////////////////////////////////////////////////////////
}

/**
 * Print statistics (DO NOT CHANGE)
 */
void cache_c::print_stats() {
	std::cout << "------------------------------" << "\n";
	std::cout << m_name << " Hit Rate: " << (double)m_num_hits / m_num_accesses * 100 << " % \n";
	std::cout << "------------------------------" << "\n";
	std::cout << "number of accesses: " << m_num_accesses << "\n";
	std::cout << "number of hits: " << m_num_hits << "\n";
	std::cout << "number of misses: " << m_num_misses << "\n";
	std::cout << "number of writes: " << m_num_writes << "\n";
	std::cout << "number of writebacks: " << m_num_writebacks << "\n";
}

