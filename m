From: "Jim Hull" <jim.hull@hp.com>
Date: Thu, 02 Jun 2005 19:00:22 +0000
Subject: RE: flush_icache_range
Message-Id: <200506021900.MAA07899@lucy.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David: 

> I guess what you're saying is that the architecture imposes no such
> constraint and the OS _must_ flush at the minium stride across all
> CPUs.  Right?

Yes.  And note that for current implementations, the minimum stride is
determined by the L1 cache, not the L3 (but you shouldn't count on that either -
just ask PAL about all the levels, and take the minimum).

 -- Jim


