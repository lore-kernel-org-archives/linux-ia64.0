From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 23 Nov 2004 17:16:28 +0000
Subject: Re: SELinux & ia64
Message-Id: <41A3706C.8080107@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A35397.1080001@sgi.com> <20041123161317.GA2775@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041123161317.GA2775@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, selinux@tycho.nsa.gov

Hi Matthew,

Thanks for the reply.  In this instance, buf[0] points to a char* -- it 
might not be aligned to u16.

Prarit

Matthew Wilcox wrote:

>On Tue, Nov 23, 2004 at 10:13:27AM -0500, Prarit Bhargava wrote:
>  
>
>>I've tracked this to the usage of le32_to_cpu in 
>>
>>security/selinux/ss/policydb.c
>>
>>The code in question uses:
>>
>>   len = le32_to_cpu(buf[0]);
>>
>>and should be
>>
>>   len = le32_to_cpu(get_unaligned(&buf[0]));
>>    
>>
>
>It would probably be better to find out why buf is unaligned, and see
>if we can make other changes to make it aligned.  If we can't, then I
>recommend a new macro for accessing this element, rather than nest
>the macros like this.  It could look something like:
>
>	len = get_unaligned_le32(buf + 0);
>
>and be implemented perhaps as:
>
>static u32 get_unaligned_le32(u32 *buf)
>{
>	char *bufc = buf;
>	return *bufc | (*(bufc+1) << 8) | (*(bufc+2) << 16) | (*(bufc+3) << 24);
>}
>
>  
>
