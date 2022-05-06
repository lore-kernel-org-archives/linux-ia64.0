From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 06 May 2022 17:23:48 +0000
Subject: Re: [PATCH 1/2] include/linux/nodemask.h: create node_available() helper
Message-Id: <20220506172348.GA543299@bhelgaas>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20220506015801.757918-2-liupeng256@huawei.com>
References: <20220506015801.757918-2-liupeng256@huawei.com>
In-Reply-To: <20220506015801.757918-2-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peng Liu <liupeng256@huawei.com>
Cc: bhelgaas@google.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, lorenzo.pieralisi@arm.com, guohanjun@huawei.com, sudeep.holla@arm.com, rafael@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, logang@deltatee.com, martin.oliveira@eideticom.com, thunder.leizhen@huawei.com, axboe@kernel.dk, kch@nvidia.com, ming.lei@redhat.com, shinichiro.kawasaki@wdc.com, mcgrof@kernel.org, jiangguoqing@kylinos.cn, jpittman@redhat.com, dave@stgolabs.net, wangkefeng.wang@huawei.com, linux-block@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Subject line convention looks like "numa: ..."

On Fri, May 06, 2022 at 01:58:00AM +0000, Peng Liu wrote:
> Lots of code dose
               does

> 	node != NUMA_NO_NODE && !node_online(node)
> or
> 	node = NUMA_NO_NODE || node_online(node)
> so create node_available to do this to simplify code.
            node_available()

I'm not really sure what meaning "node_available" conveys, though.
Probably just because I don't understand NUMA.

Should the test for NUMA_NO_NODE be folded into node_state() or
node_online() directly instead of adding a new node_available()
interface?

NUMA_NO_NODE is -1.  It's not clear to me that node_state()/
node_isset()/test_bit() would do the right thing given -1.  I doubt
all node_online() callers ensure they don't pass NUMA_NO_NODE.

> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -70,6 +70,7 @@
>   *
>   * int node_online(node)		Is some node online?
>   * int node_possible(node)		Is some node possible?
> + * int node_available(node)		Is some node available(online or NUMA_NO_NODE)?

Existing file generally fits in 80 columns; follow that lead unless
you have a really good reason.  E.g., maybe this?

  + * int node_available(node)		Node online or NUMA_NO_NODE
