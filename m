From: Martin Pool <mbp@samba.org>
Date: Wed, 30 Jul 2003 03:55:43 +0000
Subject: Re: Conversion between different types on IA-64
Message-Id: <marc-linux-ia64-105953748000656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105951522415896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105951522415896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 30 Jul 2003, CH Gowri Kumar <gkumar@csa.iisc.ernet.in> wrote:
> Hi all,
> Can anyone point me to a source of how to convert from a 
> wider size to narrow size (long to int, int to char etc.) on IA-64?
> 
> For the other way round(narrow to wider), I could find SXT(sign extend) 
> and ZXT(zero extend) instructions.
> 
> gcc seems(but not sure) to be storing the original value and loading it 
> using the appropriate LD* instruction.

In C just a cast ought to do it.

In asm it seems like you can either ST and then LD4/LD2/LD1, or use
AND or EXTR.

Sorry if I'm misunderstanding your question.

-- 
Martin 
