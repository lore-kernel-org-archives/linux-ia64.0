From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 02 Oct 2012 17:29:19 +0000
Subject: Re: [RFC v9 PATCH 01/21] memory-hotplug: rename remove_memory() to offline_memory()/offline_pages()
Message-Id: <CAHGf_=rNSmtxw2JL2g+b-yq9KTFZPWBp90KtERJouDS-vv3zWw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
 <1346837155-534-2-git-send-email-wency@cn.fujitsu.com> <506509E4.1090000@gmail.com>
 <50651E68.3040208@jp.fujitsu.com> <CAHGf_=oJ_Jmjqcdr4cPJghf7PX+vfmZe=CV2sdQQhS5agzG15w@mail.gmail.com>
 <506A4100.7070305@jp.fujitsu.com>
In-Reply-To: <506A4100.7070305@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Ni zhan Chen <nizhan.chen@gmail.com>, wency@cn.fujitsu.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

>> Then, you introduced bisect breakage. It is definitely unacceptable.
>
> What is "bisect breakage" meaning?

Think what's happen when only applying path [1/21].
