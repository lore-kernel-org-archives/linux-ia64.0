From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 23 Nov 2004 16:13:17 +0000
Subject: Re: SELinux & ia64
Message-Id: <20041123161317.GA2775@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A35397.1080001@sgi.com>
In-Reply-To: <41A35397.1080001@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 23, 2004 at 10:13:27AM -0500, Prarit Bhargava wrote:
> I've tracked this to the usage of le32_to_cpu in 
> 
> security/selinux/ss/policydb.c
> 
> The code in question uses:
> 
>    len = le32_to_cpu(buf[0]);
> 
> and should be
> 
>    len = le32_to_cpu(get_unaligned(&buf[0]));

It would probably be better to find out why buf is unaligned, and see
if we can make other changes to make it aligned.  If we can't, then I
recommend a new macro for accessing this element, rather than nest
the macros like this.  It could look something like:

	len = get_unaligned_le32(buf + 0);

and be implemented perhaps as:

static u32 get_unaligned_le32(u32 *buf)
{
	char *bufc = buf;
	return *bufc | (*(bufc+1) << 8) | (*(bufc+2) << 16) | (*(bufc+3) << 24);
}

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
