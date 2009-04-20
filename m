From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 20 Apr 2009 16:45:06 +0000
Subject: ate_resource->lowest_free_index signed or unsigned?
Message-Id: <49ECA692.2040007@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In arch/ia64/include/asm/sn/pcibr_provider.h:94

struct ate_resource{
        u64 *ate;
        u64 num_ate;
        u64 lowest_free_index;
};

as you see lowest_free_index is unsigned,

but in alloc_ate_resource() and free_ate_resource() it is
treated as signed:

static inline void free_ate_resource(struct ate_resource *ate_resource,
                                     int start)
{
        mark_ate(ate_resource, start, ate_resource->ate[start], 0);
        if ((ate_resource->lowest_free_index > start) ||
            (ate_resource->lowest_free_index < 0))
                ate_resource->lowest_free_index = start;
}

/*
 * alloc_ate_resource:  Allocate the requested number of ATEs.
 */
static inline int alloc_ate_resource(struct ate_resource *ate_resource,
                                     int ate_needed)
{
        int start_index;

        /*
         * Check for ate exhaustion.
         */
        if (ate_resource->lowest_free_index < 0)
                return -1;

        /*
         * Find the required number of free consecutive ates.
         */
        start_index             find_free_ate(ate_resource, ate_resource->lowest_free_index,
                          ate_needed);
        if (start_index >= 0)
                mark_ate(ate_resource, start_index, ate_needed, ate_needed);

        ate_resource->lowest_free_index             find_free_ate(ate_resource, ate_resource->lowest_free_index, 1);

        return start_index;
}

should it be signed instead?
