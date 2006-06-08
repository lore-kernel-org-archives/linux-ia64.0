From: Jes Sorensen <jes@sgi.com>
Date: Thu, 08 Jun 2006 08:43:28 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <yq0ac8orqa7.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "vamsi" = vamsi krishna <vamsi.krishnak@gmail.com> writes:

vamsi> Also why IPF kernel differs from other systems where the mmap
vamsi> space is below &_etext where as on other systems its above
vamsi> &_end. ??

There is no requirement for this - it also bit ld.so initially.

If you post your code, people could take a look as to what you're
doing and possibly tell you what you do wrong.

Jes
