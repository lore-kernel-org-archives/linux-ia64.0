From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 09 Nov 2005 01:18:23 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511090118.jA91INg21964@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magenheimer, Dan wrote on Tuesday, November 08, 2005 4:46 PM
> Not completely bogus.  Flexibility always leads to combinatorial
> explosion, yet OSVs still support a wide variety of devices,
> filesystems, GUIs, etc.  Exposing the ability to more easily
> change pagesize is just one more degree of flexibility.

I think you are mixing the argument here.  Single kernel image does
not equate to better/easier OSD/ISV certification.  I boot this
fancy-one-image-handle-all-cases kernel with half a dozen special
boot time arguments that changes page-size, xen, numa, cpuset,
scheduler parameters.  And then call up the ISV and ask for support,
are they going to support that special configuration?  Referring
to Rohit Seth's earlier point: ISV is going to say: "we don't support
that configuration, boot without any boot time argument and call back".

I don't see how ISV/OSD's certification job is any easier.  Perhaps,
even harder because unless one covers the entire permutation of all
the options, it will never be complete.

Having a flexibility does not automatically grant you certification
for all configurations unless someone spend the time and effort in
validating them all.  There is no shortcut here.

- Ken

