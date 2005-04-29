From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 15:24:32 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17010.20912.619210.652545@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 29 Apr 2005 08:20:25 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> On Fri, 29 Apr 2005, David Mosberger wrote:
  Christoph> y is defined in its own block.

  >> Ummh, macros 101: think about what happens for _raw_write_unlock(y)...

  Christoph> Not if its defined in an inline function.

I thought it was declared inside a macro.  Never mind.

	--david
