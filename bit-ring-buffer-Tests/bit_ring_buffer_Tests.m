//
//  bit_ring_buffer_Tests.m
//  bit-ring-buffer-Tests
//
//  Created by Jan on 24.09.17.
//  Copyright © 2017 Jan. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <stdbool.h>

#include "bitset.h"
#include "bit-ring-buffer.h"


@interface bit_ring_buffer_Tests : XCTestCase

@end

@implementation bit_ring_buffer_Tests

#if 0
- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}
#endif

static void
test_bitset_with_bit_count(id self, jx_bitset *set) {
	size_t bit_count = jx_bitset_get_bit_count(set);
	
	for (size_t i = 0; i < bit_count; i += 1) {
		jx_bitset_set(set, i, true);
		XCTAssertTrue(jx_bitset_get(set, i), "Unexpected value for bit %zu", i);
		
		XCTAssertEqual(jx_bitset_popcount(set), (i + 1));
	}
	
	const size_t max_popcount = bit_count;

	for (size_t i = 0; i < bit_count; i += 1) {
		jx_bitset_set(set, i, false);
		XCTAssertFalse(jx_bitset_get(set, i), "Unexpected value for bit %zu", i);
		
		XCTAssertEqual(jx_bitset_popcount(set), (max_popcount - i - 1),
					   "Unexpected number of bits set to true for bit count %zu.", bit_count);
	}
	
#if JX_BITSET_INVERT_BIT_ORDER
	jx_bitset_set_all_to_true(set);
	XCTAssertEqual(jx_bitset_popcount(set), bit_count,
				   "Unexpected number of bits after setting all to true for bit count %zu.", bit_count);
	
	jx_bitset_shift_all_bits_forward(set);
	XCTAssertEqual(jx_bitset_popcount(set), (bit_count - 1),
				   "Unexpected number of bits set to true after shift for bit count %zu.", bit_count);
#endif
}

static void
test_bitset_with_bit_count_alternating_values(id self, jx_bitset *set) {
	size_t bit_count = jx_bitset_get_bit_count(set);
	
	for (size_t i = 0; i < bit_count; i += 2) {
		jx_bitset_set(set, i, true);
		XCTAssertTrue(jx_bitset_get(set, i), "Unexpected value for bit %zu", i);
		
		XCTAssertEqual(jx_bitset_popcount(set), (i/2 + 1));
	}
	
	const size_t max_alternating_popcount = bit_count/2 + bit_count % 2;

	for (size_t i = 0; i < bit_count; i += 2) {
		jx_bitset_set(set, i, false);
		XCTAssertFalse(jx_bitset_get(set, i), "Unexpected value for bit %zu", i);
		
		XCTAssertEqual(jx_bitset_popcount(set), (max_alternating_popcount - i/2 - 1),
					   "Unexpected number of bits set to true for bit count %zu.", bit_count);
	}
}

static void
test_stack_bitset_of_size(id self, size_t bit_count)
{
	jx_bitset set;
	jx_bitset_init(&set, bit_count);
	
	test_bitset_with_bit_count(self, &set);
	jx_bitset_clear(&set);
	test_bitset_with_bit_count_alternating_values(self, &set);
	
	jx_bitset_done(&set);
}

static void
test_heap_bitset_of_size(id self, size_t bit_count)
{
	jx_bitset *set = jx_bitset_new(bit_count);
	
	test_bitset_with_bit_count(self, set);
	jx_bitset_clear(set);
	test_bitset_with_bit_count_alternating_values(self, set);

	jx_bitset_free(set);
}

static void
test_bitset_of_size(id self, size_t bit_count)
{
	test_stack_bitset_of_size(self, bit_count);
	test_heap_bitset_of_size(self, bit_count);
}

- (void)testBitset
{
	test_bitset_of_size(self, 1);
	test_bitset_of_size(self, 2);
	test_bitset_of_size(self, 3);
	test_bitset_of_size(self, 4);
	test_bitset_of_size(self, 5);
	test_bitset_of_size(self, 6);
	test_bitset_of_size(self, 7);
	test_bitset_of_size(self, 8);
	test_bitset_of_size(self, 9);
	test_bitset_of_size(self, 10);
	test_bitset_of_size(self, 11);
	test_bitset_of_size(self, 12);
	test_bitset_of_size(self, 13);
	test_bitset_of_size(self, 14);
	test_bitset_of_size(self, 15);
	test_bitset_of_size(self, 16);
	test_bitset_of_size(self, 31);
	test_bitset_of_size(self, 32);
	test_bitset_of_size(self, 63);
	test_bitset_of_size(self, 64);
	test_bitset_of_size(self, 65535);
	test_bitset_of_size(self, 65536);
	test_bitset_of_size(self, 65537);
}


const bool value_1 = false;
const bool value_2 = true;
const bool value_3 = false;
const bool value_4 = true;
const bool value_5 = false;
const bool value_6 = true;
const bool value_7 = false;

void
test_bit_ring_buffer_fill(id self, jx_bit_ring_buffer *buf)
{
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_1), true,
				   "Cannot add to ring buffer.");
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_2), true,
				   "Cannot add to ring buffer.");
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_3), true,
				   "Cannot add to ring buffer.");
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_4), true,
				   "Cannot add to ring buffer.");
	
	XCTAssertEqual(jx_bit_ring_buffer_is_full(buf), true,
				   "Ring buffer should be full.");
}

static void
test_bit_ring_buffer_core(id self, jx_bit_ring_buffer *buf)
{
	XCTAssertEqual(jx_bit_ring_buffer_get_allocated_size(buf), 4,
				   "Ring buffer should provide storage for the right number of elements.");
	
	XCTAssertEqual(jx_bit_ring_buffer_is_empty(buf), true,
				   "Ring buffer should be empty.");
	
	test_bit_ring_buffer_fill(self, buf);
	
	XCTAssertNotEqual(jx_bit_ring_buffer_add(buf, value_5), true,
					  "Shouldn't be able to add to a full ring buffer.");
	
	XCTAssertEqual(*jx_bit_ring_buffer_peek(buf), value_1,
				   "Unexpected head of ring buffer (peek).");
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_1,
				   "Unexpected head of ring buffer (pop).");
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_2,
				   "Unexpected head of ring buffer (pop).");
	
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_5), true,
				   "Cannot add to ring buffer.");
	XCTAssertEqual(jx_bit_ring_buffer_add(buf, value_6), true,
				   "Cannot add to ring buffer.");
	XCTAssertNotEqual(jx_bit_ring_buffer_add(buf, value_7), true,
					  "Shouldn't be able to add to ring buffer.");
	
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_3,
				   "Unexpected head of ring buffer (pop).");
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_4,
				   "Unexpected head of ring buffer (pop).");
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_5,
				   "Unexpected head of ring buffer (pop).");
	XCTAssertEqual(*jx_bit_ring_buffer_pop(buf), value_6,
				   "Unexpected head of ring buffer (pop).");
	XCTAssertEqual(jx_bit_ring_buffer_pop(buf), NULL,
				   "Shouldn't be able to pop from an empty ring buffer.");
	
	XCTAssertEqual(jx_bit_ring_buffer_is_empty(buf), true,
				   "Ring buffer should be empty.");
	
	test_bit_ring_buffer_fill(self, buf);
	
	XCTAssertNotEqual(jx_bit_ring_buffer_add(buf, value_2), true,
					  "Shouldn't be able to add to a full ring buffer.");
	
	XCTAssertEqual(jx_bit_ring_buffer_population_count(buf), 2,
				   "Unexpected head of ring buffer (peek).");

	jx_bit_ring_buffer_add_with_overwrite(buf, value_2);
	XCTAssertEqual(*jx_bit_ring_buffer_peek(buf), value_2,
				   "Unexpected head of ring buffer (peek).");

	XCTAssertEqual(jx_bit_ring_buffer_population_count(buf), 3,
				   "Unexpected head of ring buffer (peek).");
}

static void
test_stack_bit_ring_buffer(id self)
{
	struct jx_bit_ring_buffer buf;
	jx_bit_ring_buffer_init(&buf, 4);
	
	test_bit_ring_buffer_core(self, &buf);
	
	jx_bit_ring_buffer_done(&buf);

}

static void
test_heap_bit_ring_buffer(id self)
{
	struct jx_bit_ring_buffer *buf = jx_bit_ring_buffer_new(4);
	
	test_bit_ring_buffer_core(self, buf);
	
	jx_bit_ring_buffer_free(buf);
}

static void
test_bit_ring_buffer(id self)
{
	test_stack_bit_ring_buffer(self);
	test_heap_bit_ring_buffer(self);
}

- (void)testBitRingBuffer
{
	test_bit_ring_buffer(self);
}

#if 0
- (void)testPerformanceExample {
	// This is an example of a performance test case.
	[self measureBlock:^{
		// Put the code you want to measure the time of here.
	}];
}
#endif

@end
