From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2004 19:16:42 +0000
Subject: RE: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221C900@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: cngam@sgi.com, Matthew Wilcox <matthew@wil.cx>, Grant Grundler <iod00d@hp.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Pat Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>Yes, after looking at Grant's review/suggestion, we found that we can 
>actually just use raw_pci_ops.  This will work well for us.  We have 
>incoorporated this change.  No changes in pci/pci.c needed.

Good.  Let's try to make some forward progress here.  I'd like
to see the patches broken into a sequence something like this:

1) Add new interfaces to header files to support any new API
   needed by new files
2) Create all the new files (plain copies of old files where
   a move is involved).
3) Functional changes to copied files.
4) Whitespace cleanup of copied files.
5) Point Makefiles to new files
6) Delete all the old/unused files.
7) Delete any API in headers that were only used by old files.

We'll need to coordinate with some other maintainrs for
drivers/pci/hotplug/Kconfig and drivers/scsi/qla1280.c,
but I'm ok with running all the other parts through the
ia64 tree.

This follows the usual guidelines of a sequence of steps where
the system is buildable+usable at each stage.

-Tony
