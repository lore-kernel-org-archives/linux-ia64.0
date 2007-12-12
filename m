From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 12 Dec 2007 11:07:37 +0000
Subject: Re: [PATCH 1/3] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
Message-Id: <475FC0F9.80605@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959881.6586.6.camel@elijah.suse.cz>
In-Reply-To: <1196959881.6586.6.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> Hello,
> 
> On Thu, Dec 06, 2007 at 05:51:21PM +0100, Petr Tesarik wrote:
>> The RSE synchronization will need a TIF_ flag, but all work-to-be-done
>> bits are already used, so we'll have to multiplex TIF_NOTIFY_RESUME
>> again.
>>
> 
> Yes, I knew this was coming. I think it is okay to multiplex on
> TIF_NOITFY_RESUME. However, I think it would be cleaner and likely
> more efficient to add yet another TIF flags for perfmon instead of
> adding the pfm_needs_checking field. That new TIF flag would not have
> to be in the low 7 bits. It could be higher because it would not be
> checked by the assembly code but rather in do_notify_resume_user().
> The TIF limitation is just in the assembly code.
> 
> Any comments?

I'm making a mental note to review this later for optimization. AFAICS
fetching the pfm_needs_checking field is not too costly, but of course
it's an extra memory reference (and possibly a cache miss).

On a related note, I think that we should be able to use all 8 bits for
pending work TIF_ bits despite the brain-damaged sign extension in "and
imm8", but I don't have the time now to go through all uses of the
thread flags in assembly. Not really sure if it's worth adding one TIF_
bit, because we'll pretty certainly need one more bit in the future...

Anyway, I'd like to push the changes to ptrace first, because that's
currently broken.

Kind regards,
Petr Tesarik
