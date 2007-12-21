From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 21 Dec 2007 05:58:12 +0000
Subject: I have a problem about changing a bundle, help!
Message-Id: <476B55F4.7000205@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!
	
	Are the following statements safe? Is there any coherence problem?
And why?

	/* change the instruction */
	memcpy(ins_addr, ins_buf, sizeof(struct ia64_bundle));
 	flush_icache_range(ins_addr, ins_addr + sizeof(struct ia64_bundle));

	I have make sure that just one thread changes the instruction(bundle),
but maybe a lot of threads execute the instruction in the same time.

	Is any thread executes an error instruction(maybe an error bundle
combined with old bundle and new bundle, or other) in some condition?

	If the statements are unsafe, how can i change a bundle safely?

Best Regards!
Lai Jiangshan
