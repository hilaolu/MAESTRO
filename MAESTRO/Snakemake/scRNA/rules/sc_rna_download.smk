
import os

def get_fastq_urls(wildcards):
    """Return the list of remote FASTQ URLs for a sample, from samples.json."""
    r1_files = FILES[wildcards.sample]["R1"]
    r2_files = FILES[wildcards.sample]["R2"]
    return {"R1": r1_files, "R2": r2_files}

def get_local_fastqs(wildcards, read_key):
    """Map remote URLs to local temp paths under Result/Fastq/{sample}/."""
    urls = FILES[wildcards.sample][read_key]
    return [temp("Result/Fastq/{sample}/{basename}".format(
        sample=wildcards.sample,
        basename=os.path.basename(url)
    )) for url in urls]


if config["platform"] == "10x-genomics":
    rule download_fastq:
        """Download all FASTQ files for a 10x-genomics sample."""
        output:
            r1 = temp("Result/Fastq/{sample}/{sample}_R1.fastq.gz"),
            r2 = temp("Result/Fastq/{sample}/{sample}_R2.fastq.gz"),
        params:
            r1_urls = lambda wildcards: ' '.join(FILES[wildcards.sample]["R1"]),
            r2_urls = lambda wildcards: ' '.join(FILES[wildcards.sample]["R2"]),
            download_cmd = config.get("download_command", "wget -O"),
        log:
            "Result/Log/{sample}_download.log"
        benchmark:
            "Result/Benchmark/{sample}/{sample}_Download.benchmark"
        shell:
            """
            # Download R1 files and concatenate
            first=true
            for url in {params.r1_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r1} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r1}.part "$url" >> {log} 2>&1
                    cat {output.r1}.part >> {output.r1}
                    rm -f {output.r1}.part
                fi
            done

            # Download R2 files and concatenate
            first=true
            for url in {params.r2_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r2} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r2}.part "$url" >> {log} 2>&1
                    cat {output.r2}.part >> {output.r2}
                    rm -f {output.r2}.part
                fi
            done
            """

elif config["platform"] == "Dropseq":
    rule download_fastq:
        """Download all FASTQ files for a Dropseq sample."""
        output:
            r1 = temp("Result/Fastq/{sample}/{sample}_R1.fastq.gz"),
            r2 = temp("Result/Fastq/{sample}/{sample}_R2.fastq.gz"),
        params:
            r1_urls = lambda wildcards: ' '.join(FILES[wildcards.sample]["R1"]),
            r2_urls = lambda wildcards: ' '.join(FILES[wildcards.sample]["R2"]),
            download_cmd = config.get("download_command", "wget -O"),
        log:
            "Result/Log/{sample}_download.log"
        benchmark:
            "Result/Benchmark/{sample}/{sample}_Download.benchmark"
        shell:
            """
            # Download R1 files and concatenate
            first=true
            for url in {params.r1_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r1} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r1}.part "$url" >> {log} 2>&1
                    cat {output.r1}.part >> {output.r1}
                    rm -f {output.r1}.part
                fi
            done

            # Download R2 files and concatenate
            first=true
            for url in {params.r2_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r2} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r2}.part "$url" >> {log} 2>&1
                    cat {output.r2}.part >> {output.r2}
                    rm -f {output.r2}.part
                fi
            done
            """
