From: Paul Jackson <pj@sgi.com>
Date: Sun, 29 Jan 2006 05:04:12 +0000
Subject: Re: [PATCH 001/003]Fix unify mapping from pxm to node id.
Message-Id: <20060128210412.0c050675.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060123165644.C147.Y-GOTO@jp.fujitsu.com>
	<20060126074846.1a6dd300.pj@sgi.com>
	<20060128122758.CF50.Y-GOTO@jp.fujitsu.com>
	<20060127231517.4c0ce573.pj@sgi.com>
	<20060129034434.GO7306@localhost>
In-Reply-To: <20060129034434.GO7306@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: y-goto@jp.fujitsu.com, akpm@osdl.org, apw@shadowen.org, bob.picco@hp.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, ak@suse.de, len.brown@intel.com, discuss@x86-64.org

Bob wrote:
> MAX_PXM_DOMAINS is defined in include/acpi/acpi_numa.h.  So I'm confused.

Ah - there it is.  My mistake.

I did not realize that the list set of 3 patches was in addition
to, rather than replacing the previous patches.

I am retesting my build now -- I should be able to report
success in a few hours.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
