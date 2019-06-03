From: Wei Yang <richard.weiyang@gmail.com>
Date: Mon, 03 Jun 2019 21:49:32 +0000
Subject: Re: [PATCH v3 05/11] drivers/base/memory: Pass a block_id to init_memory_block()
Message-Id: <20190603214932.3xsvxwiiutcve4tz@master>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-6-david@redhat.com>
In-Reply-To: <20190527111152.16324-6-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Mon, May 27, 2019 at 01:11:46PM +0200, David Hildenbrand wrote:
>We'll rework hotplug_memory_register() shortly, so it no longer consumes
>pass a section.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c | 15 +++++++--------
> 1 file changed, 7 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index f180427e48f4..f914fa6fe350 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -651,21 +651,18 @@ int register_memory(struct memory_block *memory)
> 	return ret;
> }
> 
>-static int init_memory_block(struct memory_block **memory,
>-			     struct mem_section *section, unsigned long state)
>+static int init_memory_block(struct memory_block **memory, int block_id,
>+			     unsigned long state)
> {
> 	struct memory_block *mem;
> 	unsigned long start_pfn;
>-	int scn_nr;
> 	int ret = 0;
> 
> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> 	if (!mem)
> 		return -ENOMEM;
> 
>-	scn_nr = __section_nr(section);
>-	mem->start_section_nr >-			base_memory_block_id(scn_nr) * sections_per_block;
>+	mem->start_section_nr = block_id * sections_per_block;
> 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
> 	mem->state = state;
> 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>@@ -694,7 +691,8 @@ static int add_memory_block(int base_section_nr)
> 
> 	if (section_count = 0)
> 		return 0;
>-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
>+	ret = init_memory_block(&mem, base_memory_block_id(base_section_nr),
>+				MEM_ONLINE);

If my understanding is correct, section_nr could be removed too.

> 	if (ret)
> 		return ret;
> 	mem->section_count = section_count;
>@@ -707,6 +705,7 @@ static int add_memory_block(int base_section_nr)
>  */
> int hotplug_memory_register(int nid, struct mem_section *section)
> {
>+	int block_id = base_memory_block_id(__section_nr(section));
> 	int ret = 0;
> 	struct memory_block *mem;
> 
>@@ -717,7 +716,7 @@ int hotplug_memory_register(int nid, struct mem_section *section)
> 		mem->section_count++;
> 		put_device(&mem->dev);
> 	} else {
>-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
>+		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
> 		if (ret)
> 			goto out;
> 		mem->section_count++;
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me
