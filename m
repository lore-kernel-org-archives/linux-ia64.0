From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 May 2004 16:10:10 +0000
Subject: Re: [PATCH] set EXEC_PAGESIZE to PAGE_SIZE
Message-Id: <16544.64226.876943.804285@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040511145923.GC23495@sgi.com>
In-Reply-To: <20040511145923.GC23495@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 May 2004 09:59:23 -0500, edwardsg@sgi.com (Greg Edwards) said:

  Greg> The number of pages allocated for the gid_t * blocks[] array
  Greg> in the group_info struct is calculated from EXEC_PAGESIZE.

Sounds like a bug in the large-groups patch then, no?

	--david
