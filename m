From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 30 Mar 2006 18:34:23 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on
Message-Id: <1143743663.9731.87.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

One other random idea...

We could call memory_present() and populate the sparsemem tables, but
only _use_ sparsemem in show_mem().  Not for normal pfn_to_page() or
pfn_valid().

-- Dave

