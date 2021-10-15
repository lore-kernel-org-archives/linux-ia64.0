From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 06:11:32 +0000
Subject: Re: [PATCH v2 03/13] powerpc: Remove func_descr_t
Message-Id: <1634277766.29y8aqzatr.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <16eef6afbf7322d0c07760ebf827b8f9f50f7c6e.1634190022.git.christophe.leroy@csgroup.eu>
        <874k9j45fm.fsf@dja-thinkpad.axtens.net>
        <b02d5211-2f00-b303-766b-d612c1bd4402@csgroup.eu>
In-Reply-To: <b02d5211-2f00-b303-766b-d612c1bd4402@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Daniel Axtens <dja@axtens.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 15, 2021 3:19 pm:
> 
> 
> Le 15/10/2021 à 00:17, Daniel Axtens a écrit :
>> Christophe Leroy <christophe.leroy@csgroup.eu> writes:
>> 
>>> 'func_descr_t' is redundant with 'struct ppc64_opd_entry'
>> 
>> So, if I understand the overall direction of the series, you're
>> consolidating powerpc around one single type for function descriptors,
>> and then you're creating a generic typedef so that generic code can
>> always do ((func_desc_t)x)->addr to get the address of a function out of
>> a function descriptor regardless of arch. (And regardless of whether the
>> arch uses function descriptors or not.)
> 
> An architecture not using function descriptors won't do much with 
> ((func_desc_t *)x)->addr. This is just done to allow building stuff 
> regardless.
> 
> I prefer something like
> 
> 	if (have_function_descriptors())
> 		addr = (func_desc_t *)ptr)->addr;
> 	else
> 		addr = ptr;

If you make a generic data type for architectures without function 
descriptors as such

typedef struct func_desc {
    char addr[0];
} func_desc_t;

Then you can do that with no if. The downside is your addr has to be 
char * and it's maybe not helpful to be so "clever".

>>   - why pick ppc64_opd_entry over func_descr_t?
> 
> Good question. At the begining it was because it was in UAPI headers, 
> and also because it was the one used in our 
> dereference_function_descriptor().
> 
> But at the end maybe that's not the more logical choice. I need to look 
> a bit more.

I would prefer the func_descr_t (with 'toc' and 'env') if you're going 
to change it.

Thanks,
Nick
