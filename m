From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 19 Dec 2002 00:21:08 +0000
Subject: Re: [Linux-ia64] installation help
Message-Id: <marc-linux-ia64-105590709805614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jane,

On Wed, Dec 18, 2002 at 04:14:44PM -0800, Jian Chen wrote:
> 
> I installed ski and nue in order to use a cross
> compiler (open 64) from Intel on IA32. As I said, the
> binary did not work when I installed the compiler. Now
> that it works after running '/etc/rc.d/init.d/ia64fmt
> start'. Do I need to reinstall the compiler?
> 
I would guess no. You would need to reinstall only if during the
installation of this compiler they need to run an IA-64 binary.

-- 
-Stephane

