From: Grant Grundler <iod00d@hp.com>
Date: Wed, 09 Feb 2005 00:59:49 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <20050209005949.GD22678@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 08, 2005 at 03:45:25PM -0800, Luck, Tony wrote:
> 2) I saw one user process failure ... while stressing the system with a
> "make -j16" kernel build, one of the complilations error'd out with a
> bizarre internal gcc error.  So possibly a register was corrupted???

Likely yes.
That's one of two errors I see on parisc-linux when a register
is corrupted (segfaults are the symptom). And unfortunately
the context switching has a corner case the tickles that bug
on a regular basis. :^(

hth,
grant
