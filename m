From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Sat, 03 Aug 2002 00:53:23 +0000
Subject: Re: [Linux-ia64] Re: CPU hotplug boot change for IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------_3D4B284BEDFB02CE0A8C_MULTIPART_MIXED_"
Message-Id: <marc-linux-ia64-105590701905901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
To: linux-ia64@vger.kernel.org

--------_3D4B284BEDFB02CE0A8C_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi David,

I removed cpu_initialized and fixed several bugs.
I tested SMP and UP kernels on 2-way Bigsur.
Please let me know if there is any problem on the patch.

Thanks,
Kimi

On Fri, 02 Aug 2002 15:18:01 -0700
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> wrote:

> Sorry, I missed to remove that. :-(
> cpu_initialized (or something like that) is needed when
> CPU Hot Plug is implemented.
> __cpu_up() must detect that the CPU has already been initialized
> and but offlined or the CPU hasn't been initialized.
> But for 2.5.29, such the variable isn't necessary.
> And as you pointed out, it should not be in setup.c.
> I'll update the patch and send it later.

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>

--------_3D4B284BEDFB02CE0A8C_MULTIPART_MIXED_
Content-Type: application/octet-stream; name="hotplug-boot-change-ia64.patch.gz"
Content-Disposition: attachment;
 filename="hotplug-boot-change-ia64.patch.gz"
Content-Transfer-Encoding: base64

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
+tYwSu1YThLYo0+c8V8XSX3lNBoAAA==

--------_3D4B284BEDFB02CE0A8C_MULTIPART_MIXED_--


