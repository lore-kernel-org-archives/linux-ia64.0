From: Masami Hiramatsu <hiramatu@sdl.hitachi.co.jp>
Date: Fri, 16 Jun 2006 15:11:10 +0000
Subject: Re: [RFC][PATCH]fix search_extable() to find correct entry
Message-Id: <4492CA0E.7050308@sdl.hitachi.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <44916017.5050006@sdl.hitachi.co.jp>
In-Reply-To: <44916017.5050006@sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Chen, Kenneth W wrote:
> Masami Hiramatsu wrote on Thursday, June 15, 2006 6:27 AM
>> I found a suspicious buggy code in the linux kernel on IA64 arch.
>> As far as I can see, search_extable() doesn't work correctly, because
>> the lookup routine expects that the address format of the
>> exception_table_entry is "IP + slot", but the compiler (gcc-3.4.5)
>> generates it as "IP + (slot << 2)". Thus the lookup routine always
>> fails to find the corresponding entry.
>> You can check it by dumping __ex_table section of vmlinux.
> 
> Chen, Kenneth W wrote on Thursday, June 15, 2006 2:22 PM
>> But the tag address in the table is also bundle aligned, which I will
>> look a bit more.
> 
> I've double checked (triple checked with sample test code below).  It's a
> false alarm. Everyone should rest assure that exception table and compiler
> do match and generates correct code.  There is no bug AFAICT.

Thank you for your comments.
I had just checked the dump of __ex_table section of vmlinux.
This time, I checked the __ex_table of running kernel.
It is true that those format is "IP + slot". So you are right.
I admit my mistake.
Please dispose the previous patch.

Thanks again.

-- 
Masami HIRAMATSU
2nd Research Dept.
Hitachi, Ltd., Systems Development Laboratory
E-mail: hiramatu@sdl.hitachi.co.jp



