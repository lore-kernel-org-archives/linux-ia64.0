From: Jes Sorensen <jes@sgi.com>
Date: Mon, 19 May 2008 12:51:28 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <yq0od72ihin.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Avi" = Avi Kivity <avi@qumranet.com> writes:

Avi> Jes Sorensen wrote:
Avi> r17 is used later on, so your patch makes it uninitialized (if I
Avi> may venture to comment about an assembly language I know nothing
Avi> about).

Oh, on ia64 the sequence is [dest] = [src] so the register usage is
covered I believe.

Avi> Maybe a bug in the instruction emulator?

Yeah it smells like it, that or in QEMU. I am not quite sure who is
responsible for this part. Does QEMU just provide registers somewhere
else and the instruction emulation reads them out of the QEMU share
space, or is there some other magic going on?

Cheers,
Jes
