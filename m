From: Tang Chen <tangchen@cn.fujitsu.com>
Date: Wed, 26 Dec 2012 03:21:02 +0000
Subject: Re: [PATCH v5 06/14] memory-hotplug: implement register_page_bootmem_info_section of sparse-vmemmap
Message-Id: <50DA6D1E.1010209@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-7-git-send-email-tangchen@cn.fujitsu.com> <50D95F51.9090007@huawei.com>
In-Reply-To: <50D95F51.9090007@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 12/25/2012 04:09 PM, Jianguo Wu wrote:
>> +
>> +		if (!cpu_has_pse) {
>> +			next =3D (addr + PAGE_SIZE)&  PAGE_MASK;
>> +			pmd =3D pmd_offset(pud, addr);
>> +			if (pmd_none(*pmd))
>> +				continue;
>> +			get_page_bootmem(section_nr, pmd_page(*pmd),
>> +					 MIX_SECTION_INFO);
>> +
>> +			pte =3D pte_offset_kernel(pmd, addr);
>> +			if (pte_none(*pte))
>> +				continue;
>> +			get_page_bootmem(section_nr, pte_page(*pte),
>> +					 SECTION_INFO);
>> +		} else {
>> +			next =3D pmd_addr_end(addr, end);
>> +
>> +			pmd =3D pmd_offset(pud, addr);
>> +			if (pmd_none(*pmd))
>> +				continue;
>> +			get_page_bootmem(section_nr, pmd_page(*pmd),
>> +					 SECTION_INFO);
>
> Hi Tang=EF=BC=8C
> 	In this case, pmd maps 512 pages, but you only get_page_bootmem() on the=
 first page.
> I think the whole 512 pages should be get_page_bootmem(), what do you thi=
nk?
>
Hi Wu,

Yes, thanks. I will fix it. :)

Thanks. :)

