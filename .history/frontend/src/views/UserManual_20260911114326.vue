<template>
  <div class="manual">
    <aside class="manual__nav">
      <header>
        <span>DEEPTRANX</span>
        <h1>操作使用手册</h1>
        <p>Crawlab 0.6.3 本地部署版</p>
      </header>
      <label class="search">
        <font-awesome-icon :icon="['fa', 'search']"/>
        <input v-model.trim="keyword" type="search" placeholder="搜索功能或问题">
        <button v-if="keyword" title="清空搜索" type="button" @click="keyword = ''">
          <font-awesome-icon :icon="['fa', 'times']"/>
        </button>
      </label>
      <nav>
        <button
          v-for="section in visibleSections"
          :key="section.id"
          :class="{active: activeSection === section.id}"
          type="button"
          @click="scrollTo(section.id)"
        >
          <font-awesome-icon :icon="section.icon"/>
          <span>{{ section.index }} {{ section.title }}</span>
        </button>
      </nav>
    </aside>

    <main ref="contentRef" class="manual__content" @scroll="updateActive">
      <header class="hero">
        <div>
          <span class="eyebrow">系统内置文档</span>
          <h2>DEEPTRANX 采集管理系统使用手册</h2>
          <p>覆盖爬虫创建、依赖配置、手动与定时执行、数据查看、日志排查和备份恢复。</p>
        </div>
        <div class="version">
          <span>系统基线</span>
          <strong>Crawlab v0.6.3</strong>
          <small>Python 3.10 统一环境</small>
        </div>
      </header>

      <div v-if="keyword && visibleSections.length === 0" class="empty">
        <font-awesome-icon :icon="['far', 'file-alt']"/>
        <strong>没有找到相关内容</strong>
        <span>可尝试搜索“爬虫”“定时任务”“数据”或“依赖”。</span>
      </div>

      <section
        v-for="section in visibleSections"
        :id="section.id"
        :key="section.id"
        class="section"
      >
        <header class="section__head">
          <span class="section__icon"><font-awesome-icon :icon="section.icon"/></span>
          <div>
            <small>{{ section.index }}</small>
            <h3>{{ section.title }}</h3>
            <p>{{ section.summary }}</p>
          </div>
        </header>
        <article v-for="block in section.blocks" :key="block.title" class="block">
          <h4>{{ block.title }}</h4>
          <ol v-if="block.steps">
            <li v-for="step in block.steps" :key="step" v-html="step"/>
          </ol>
          <ul v-if="block.items">
            <li v-for="item in block.items" :key="item" v-html="item"/>
          </ul>
          <pre v-if="block.code"><code>{{ block.code }}</code></pre>
          <div v-if="block.note" class="note" :class="block.note.type || 'info'">
            <font-awesome-icon
              :icon="block.note.type === 'warning' ? ['fa', 'exclamation-triangle'] : ['fa', 'info-circle']"
            />
            <span v-html="block.note.text"/>
          </div>
        </article>
      </section>

      <footer>
        <img alt="" src="/brand/mark.svg">
        <div><strong>DEEPTRANX 采集管理系统</strong><span>本手册与当前本地部署配置同步维护</span></div>
      </footer>
    </main>
  </div>
</template>

<script lang="ts">
import {computed, defineComponent, onMounted, ref} from 'vue';

type Block = {
  title: string;
  steps?: string[];
  items?: string[];
  code?: string;
  note?: {type?: 'info' | 'warning'; text: string};
};

type Section = {
  id: string;
  index: string;
  title: string;
  summary: string;
  icon: [string, string];
  keywords: string[];
  blocks: Block[];
};

const sections: Section[] = [
  {
    id: 'quick-start', index: '01', title: '快速开始', icon: ['fa', 'rocket'],
    summary: '完成首次登录和一次采集任务的最短操作路径。',
    keywords: ['登录', '首页', '流程', '导航'],
    blocks: [
      {
        title: '首次登录',
        steps: [
          '访问 <code>http://localhost:8080</code> 并使用管理员账号登录。',
          '首次验收后，在右上角用户菜单的“我的设置”中立即修改默认密码。',
          '进入“节点”，确认 Master 节点为“在线”且已启用。',
        ],
        note: {type: 'warning', text: '账号、密码和 API Token 均为敏感信息，请勿写入爬虫源码、压缩包或公开日志。'},
      },
      {
        title: '一次完整采集流程',
        steps: [
          '创建项目，用于归类同一站点或数据产线的爬虫。',
          '创建爬虫并填写命令，如 <code>python main.py --domain business --max-pages 1</code>。',
          '在爬虫“文件”页上传<strong>解压后的项目文件</strong>，确认根目录存在 <code>main.py</code>。',
          '按需安装依赖，点击运行，在“任务”页查看日志与结果。',
          '手动运行稳定后再创建并启用定时任务。',
        ],
      },
    ],
  },
  {
    id: 'overview', index: '02', title: '首页、节点与项目', icon: ['fa', 'home'],
    summary: '查看系统概况、执行节点状态，并按业务组织爬虫。',
    keywords: ['首页', '节点', 'Master', '项目', '统计', '并发'],
    blocks: [
      {
        title: '首页指标',
        items: [
          '<strong>活跃节点：</strong>当前在线并可接收任务的节点数量。',
          '<strong>项目、爬虫、定时任务：</strong>系统内对应对象的总量。',
          '<strong>任务总数与错误任务：</strong>用于快速判断近期运行是否稳定。',
          '<strong>结果总数：</strong>Crawlab 结果集合记录数，不等于业务 MongoDB 中全部数据。',
        ],
      },
      {
        title: '节点',
        items: [
          '当前为单 Master 部署，由 Master 调度并直接执行爬虫。',
          '任务长期停在“待执行”时，检查节点是否在线以及运行器并发是否已满。',
          '未来任务量增大时可增加 Worker，当前无需在页面手工创建节点。',
        ],
      },
      {
        title: '项目',
        steps: [
          '进入“项目”点击新增，填写名称和说明。',
          '在新建或编辑爬虫时选择所属项目。',
          '链接采集、正文采集、清洗与导出可放在同一项目；测试与生产建议分开。',
        ],
      },
    ],
  },
  {
    id: 'spiders', index: '03', title: '爬虫', icon: ['fa', 'spider'],
    summary: '管理代码文件、执行命令、参数、结果集合和运行记录。',
    keywords: ['爬虫', '文件', '上传', '命令', 'Python', 'zip', '结果集合'],
    blocks: [
      {
        title: '创建爬虫',
        steps: [
          '点击新增，填写名称、所属项目、执行命令和说明。',
          '命令统一使用 Python 3.10，推荐 <code>python main.py</code> 或带参数的完整命令。',
          '“结果集合”应与适配脚本双写到 Crawlab 的集合名称一致。',
          '保存后进入详情，上传文件并先进行小范围测试。',
        ],
      },
      {
        title: '上传文件',
        steps: [
          '进入爬虫详情的“文件”标签，点击上传文件或上传文件夹。',
          '上传解压后的项目内容，确保根目录直接存在 <code>main.py</code>。',
          '刷新文件树，双击入口文件确认能够显示源码。',
          'ZIP 未自动解压时，执行命令会因找不到入口文件而失败。',
        ],
        note: {type: 'warning', text: '日志出现 <code>can\'t open file .../main.py</code> 时，先检查文件页、入口层级和上传是否成功。'},
      },
      {
        title: '命令与结果',
        items: [
          '<strong>固定参数：</strong>直接写入命令；临时页数、日期可在运行弹窗中填写。',
          '<strong>路径：</strong>优先使用相对路径，任务工作目录就是爬虫工作区。',
          '<strong>退出码：</strong>正常结束应为 0，参数错误或未捕获异常会使任务变为错误。',
          '<strong>结果为 0：</strong>任务完成仅代表进程正常退出，还需检查日志、解析数量和数据库。',
        ],
      },
      {
        title: 'BHOL 双写约定',
        items: [
          '<strong>业务主库：</strong><code>bhol_pipeline</code>，保存任务交接、正文及清洗数据。',
          '<strong>Crawlab 结果集：</strong>同步写入，供爬虫和任务“数据”页查看。',
          '<strong>最终导出：</strong>JSONL 保存到 <code>/data/exports/bhol</code>。',
          '<strong>追溯字段：</strong>建议保留 <code>task_id</code>、<code>spider_id</code>、来源 URL 和采集时间。',
        ],
      },
    ],
  },
  {
    id: 'schedules', index: '04', title: '定时任务', icon: ['fa', 'clock'],
    summary: '按 Cron 表达式自动创建任务，适合每日或周期性采集。',
    keywords: ['定时任务', '计划', 'Cron', '启用', '每日'],
    blocks: [
      {
        title: '创建与启动',
        steps: [
          '先手动运行目标爬虫，确认文件、依赖、命令和数据写入正常。',
          '点击新增，选择爬虫，填写 Cron，格式为 <code>分 时 日 月 周</code>。',
          '当前单节点环境选择“随机节点”或明确选择 Master。',
          '保存后打开“启用”开关，并核对页面显示的下次运行时间。',
          '在定时任务详情的“任务”页检查实际触发记录。',
        ],
      },
      {
        title: 'Cron 示例',
        code: `0 2 * * *      每天 02:00
30 8 * * *     每天 08:30
0 */6 * * *    每 6 小时
0 9 * * 1-5    周一至周五 09:00
0 0 1 * *      每月 1 日 00:00`,
        note: {text: '系统时区为 <code>Asia/Shanghai</code>，Cron 不包含秒字段。关闭计划只阻止后续触发，不终止已运行任务。'},
      },
    ],
  },
  {
    id: 'tasks', index: '05', title: '任务与日志', icon: ['fa', 'tasks'],
    summary: '查看每次执行的状态、节点、命令、日志、耗时和结果。',
    keywords: ['任务', '日志', '错误', '取消', '结果', '状态'],
    blocks: [
      {
        title: '状态说明',
        items: [
          '<strong>待执行：</strong>已进入队列，等待运行器。',
          '<strong>运行中：</strong>脚本进程正在执行。',
          '<strong>已完成：</strong>退出码为 0，仍需结合日志与结果判断业务成功。',
          '<strong>错误：</strong>返回非 0，查看错误信息和日志末尾堆栈。',
          '<strong>已取消或异常：</strong>被人工停止、容器重启或进程异常中断。',
        ],
      },
      {
        title: '查看日志与数据',
        steps: [
          '进入任务详情，在“日志”页查看标准输出和错误输出。',
          '实时运行时开启自动刷新；排错重点看最早异常与最后一段堆栈。',
          '“数据”页显示关联结果集合，可调整列、搜索、筛选和导出。',
          '任务完成但结果为 0 时，检查网站响应、解析规则、去重逻辑和双写开关。',
        ],
      },
    ],
  },
  {
    id: 'data-sources', index: '06', title: '数据源', icon: ['fa', 'database'],
    summary: '保存外部数据库连接配置，供爬虫或后续业务功能引用。',
    keywords: ['数据源', 'MongoDB', 'MySQL', '连接', 'bhol_pipeline'],
    blocks: [
      {
        title: '功能边界',
        items: [
          '支持管理 MongoDB、MySQL、PostgreSQL、SQL Server、SQLite、Elasticsearch、Kafka 等连接。',
          '数据源管理“如何连接”，不会自动把任意数据库集合显示在 Crawlab 任务结果页。',
          '爬虫与任务“数据”页读取 Crawlab 结果集合；<code>bhol_pipeline</code> 完整数据由双写脚本保存。',
        ],
        note: {type: 'warning', text: '新增数据源后，爬虫代码仍需主动读取配置并执行查询或写入。'},
      },
      {
        title: '当前 MongoDB 配置',
        steps: [
          '新增数据源并选择 MongoDB。',
          '容器内部主机填写 <code>mongo</code>，端口填写 <code>27017</code>。',
          '数据库填写 <code>bhol_pipeline</code>；当前内部网络无认证时用户名和密码留空。',
          '若状态离线，确认使用服务名 <code>mongo</code> 而不是 <code>localhost</code>。',
        ],
      },
    ],
  },
  {
    id: 'dependencies', index: '07', title: '依赖与 Python 3.10', icon: ['fa', 'puzzle-piece'],
    summary: '管理节点依赖，镜像默认使用 Python 3.10 虚拟环境。',
    keywords: ['依赖', 'Python 3.10', 'pip', 'requirements', '安装库'],
    blocks: [
      {
        title: '统一运行方式',
        items: [
          '<code>python</code>、<code>python3</code> 与 <code>pip</code> 应指向 <code>/opt/crawlab-python</code>。',
          '运行统一使用 <code>python main.py</code>，安装统一使用 <code>python -m pip install 包名</code>。',
          '避免显式调用系统残留的 <code>python3.8</code> 或其 pip。',
        ],
        code: `python --version
python -m pip --version
python -m pip install -r requirements.txt`,
      },
      {
        title: '依赖设置、Python 与 Node.js',
        items: [
          '<strong>依赖设置：</strong>维护 Python、Node.js 的安装命令和代理地址。当前镜像已统一 Python 3.10，非维护场景不要随意修改 Python 命令。',
          '<strong>Python：</strong>查看已安装或可安装的 pip 包，支持搜索、安装、升级、卸载，并可选择全部节点或指定节点。',
          '<strong>Node.js：</strong>管理 npm 包，操作方式与 Python 依赖类似；仅 Node.js 爬虫需要使用。',
          '<strong>任务按钮：</strong>查看依赖操作的执行状态和日志；刷新按钮用于重新获取节点上的已安装依赖。',
        ],
      },
      {
        title: '通过页面安装 Python 包',
        steps: [
          '进入“依赖 > Python”，搜索包名。',
          '切换到“可安装”，选中包并点击安装；单节点部署选择 Master 或全部节点。',
          '需要覆盖已有版本时打开“升级”开关。',
          '在依赖任务记录中确认安装日志成功，再运行爬虫。',
          '长期依赖应写入爬虫 <code>requirements.txt</code> 和镜像依赖清单。',
        ],
        note: {type: 'warning', text: '容器内临时 pip 安装在重建后可能丢失。长期依赖写入 <code>deploy/requirements-spider.txt</code> 后重建镜像。'},
      },
    ],
  },
  {
    id: 'account', index: '08', title: '用户、令牌与我的设置', icon: ['fa', 'users-cog'],
    summary: '管理登录账号、API 令牌、个人资料和密码。',
    keywords: ['用户', '密码', '角色', '令牌', 'Token', '我的设置'],
    blocks: [
      {
        title: '用户与令牌',
        items: [
          '管理员可管理系统配置和全部业务对象，普通用户权限受角色限制。',
          '每位操作人员使用独立账号，不建议多人长期共用管理员账号。',
          '在“令牌”中创建用途清晰的 Token，泄露或停用后立即删除并重新签发。',
        ],
      },
      {
        title: '我的设置',
        steps: [
          '点击右上角当前用户名，选择“我的设置”。',
          '修改个人资料、登录密码或界面偏好并保存。',
          '操作结束后从用户菜单退出登录，尤其是在共享电脑上。',
        ],
      },
    ],
  },
  {
    id: 'notifications', index: '09', title: '通知与环境变量', icon: ['fa', 'bell'],
    summary: '配置任务告警，并向爬虫注入不适合硬编码的运行参数。',
    keywords: ['通知', '邮件', 'Webhook', '环境变量', '密钥'],
    blocks: [
      {
        title: '通知渠道',
        steps: [
          '进入“通知”新建配置，填写名称、说明并选择邮件或移动端 Webhook。',
          '邮件类型需填写 SMTP 服务器、端口、发件账号、密码、发件人和收件人；移动端类型需填写 Webhook 地址。',
          '保存后进入详情页，在“触发器”中选择任务完成、任务错误、结果为空或从不触发。',
          '在“模板”中填写通知标题和 Markdown 正文，保存并启用通知。',
          '运行一条符合触发条件的测试任务，确认消息送达且模板变量显示正常。',
        ],
      },
      {
        title: '页面环境变量',
        steps: [
          '进入“环境变量”，点击新增，填写变量名和值后保存。',
          '变量名使用大写字母、数字和下划线，例如 <code>BHOL_CRAWLAB_SYNC</code>。',
          '运行爬虫后，在 Python 中通过 <code>os.getenv("变量名")</code> 读取并检查日志。',
          '修改变量后重新启动任务；已经运行中的进程不会自动获得新值。',
        ],
        items: [
          'BHOL 使用 <code>BHOL_MONGO_HOST</code>、<code>BHOL_MONGO_DB</code>、<code>BHOL_EXPORT_DIR</code>、<code>BHOL_CRAWLAB_SYNC</code>。',
          '页面环境变量适合爬虫运行参数；项目根目录 <code>.env</code> 用于 Docker 服务启动配置，两者作用域不同。',
          '密码、Token 等敏感值优先放在服务器 <code>.env</code> 与容器环境中，并限制文件和系统访问权限。',
        ],
        note: {type: 'warning', text: '页面环境变量以明文形式由系统管理。对高敏感凭据，应优先采用仅管理员可访问的部署环境变量。'},
      },
    ],
  },
  {
    id: 'storage', index: '10', title: '数据保存与备份', icon: ['fa', 'archive'],
    summary: '了解系统配置、爬虫文件、业务数据和 JSONL 的保存位置。',
    keywords: ['保存', 'MongoDB', '卷', '备份', '恢复', 'JSONL'],
    blocks: [
      {
        title: '保存位置',
        items: [
          '<strong>系统数据库：</strong>MongoDB 4.2，卷 <code>deeptranx_mongo-data</code>。',
          '<strong>爬虫工作区：</strong><code>/root/crawlab_workspace</code>，卷 <code>deeptranx_crawlab-workspace</code>。',
          '<strong>Crawlab 配置：</strong><code>/root/.crawlab</code>，卷 <code>deeptranx_crawlab-data</code>。',
          '<strong>文件服务：</strong><code>/data/seaweedfs</code>，卷 <code>deeptranx_crawlab-files</code>。',
          '<strong>BHOL JSONL：</strong><code>/data/exports/bhol</code>，位于持久化导出卷。',
        ],
        note: {text: '重建容器不会自动删除命名卷；带 <code>-v</code> 的删除命令会删除卷，操作前必须备份。'},
      },
      {
        title: '备份与恢复',
        code: `# 项目根目录执行备份
powershell -ExecutionPolicy Bypass -File scripts/backup.ps1

# 恢复指定备份
powershell -ExecutionPolicy Bypass -File scripts/restore.ps1 -Source backup/备份目录`,
        items: [
          '备份包含 MongoDB、Crawlab 配置、爬虫工作区、文件服务与 BHOL 导出。',
          '恢复会替换当前数据，应先停止业务操作并检查备份完整性。',
          '重要爬虫上线、镜像升级和批量修改定时任务前建议备份。',
        ],
      },
    ],
  },
  {
    id: 'troubleshooting', index: '11', title: '常见故障排查', icon: ['fa', 'tools'],
    summary: '按文件、依赖、网络、解析、存储和系统状态快速定位问题。',
    keywords: ['故障', '失败', '结果为0', '文件为空', 'exit status 2', '容器'],
    blocks: [
      {
        title: 'exit status 2 或找不到 main.py',
        items: [
          '查看完整日志，确认文件页根目录存在 <code>main.py</code>，并与命令大小写一致。',
          '确认命令参数与脚本 <code>argparse</code> 定义一致。',
          '文件为空时关闭定时任务，重新上传解压后的文件，手动运行成功后再启用。',
          '容器重启后文件丢失时，检查 workspace、storage、files 和 repo 卷挂载。',
        ],
      },
      {
        title: '运行成功但结果为 0',
        items: [
          '检查 HTTP 状态码、重定向、验证码、访问限制和选择器匹配数量。',
          '检查域名、页数参数是否进入正确分支，以及业务库是否因已有数据全部去重。',
          '确认 <code>BHOL_CRAWLAB_SYNC=1</code>，且 Crawlab 结果集合名称与脚本一致。',
        ],
      },
      {
        title: '系统服务检查',
        code: `docker compose --project-directory . --env-file .env -f deploy/compose.yml ps
docker compose --project-directory . --env-file .env -f deploy/compose.yml logs --tail 200 crawlab
curl http://127.0.0.1:8080/api/system-info`,
        note: {text: 'MongoDB 与 Crawlab 均应为 <code>healthy</code>。页面可打开但 API 失败时，优先检查 Crawlab 日志和端口。'},
      },
    ],
  },
];

export default defineComponent({
  name: 'UserManual',
  setup() {
    const keyword = ref('');
    const activeSection = ref(sections[0].id);
    const contentRef = ref<HTMLElement>();
    const visibleSections = computed(() => {
      const query = keyword.value.toLocaleLowerCase();
      return query
        ? sections.filter(section => JSON.stringify(section).toLocaleLowerCase().includes(query))
        : sections;
    });
    const scrollTo = (id: string) => {
      contentRef.value?.querySelector<HTMLElement>(`#${id}`)?.scrollIntoView({behavior: 'smooth'});
      activeSection.value = id;
    };
    const updateActive = () => {
      const root = contentRef.value;
      if (!root) return;
      const elements = visibleSections.value
        .map(section => root.querySelector<HTMLElement>(`#${section.id}`))
        .filter((element): element is HTMLElement => Boolean(element));
      const current = elements.filter(element => element.offsetTop <= root.scrollTop + 120).pop() || elements[0];
      if (current) activeSection.value = current.id;
    };
    onMounted(updateActive);
    return {keyword, activeSection, contentRef, visibleSections, scrollTo, updateActive};
  },
});
</script>

<style scoped>
.manual { display: grid; grid-template-columns: 252px minmax(0, 1fr); min-height: 100%; background: #f3f6f5; }
.manual__nav { position: sticky; top: 0; height: calc(100vh - var(--cl-header-height) - var(--cl-tabs-view-height)); overflow: auto; border-right: 1px solid #dce4e1; background: #fff; }
.manual__nav header { padding: 24px 20px 18px; border-bottom: 1px solid #e7ecea; }
.manual__nav header span, .eyebrow { display: block; color: #167d70; font-size: 11px; font-weight: 700; }
.manual__nav h1 { margin: 5px 0 4px; color: #17201f; font-size: 21px; line-height: 1.35; }
.manual__nav header p { margin: 0; color: #77817f; font-size: 12px; }
.search { display: grid; grid-template-columns: 18px minmax(0, 1fr) 22px; align-items: center; gap: 6px; height: 36px; margin: 16px 14px 10px; padding: 0 9px; border: 1px solid #d7e0dd; border-radius: 6px; color: #7b8784; background: #f8faf9; }
.search:focus-within { border-color: #167d70; box-shadow: 0 0 0 2px rgb(22 125 112 / 10%); }
.search input, .search button { min-width: 0; border: 0; outline: 0; color: #17201f; background: transparent; }
.search input { width: 100%; font-size: 13px; } .search button { cursor: pointer; color: #7b8784; }
.manual__nav nav { display: grid; gap: 2px; padding: 2px 10px 20px; }
.manual__nav nav button { display: grid; grid-template-columns: 22px minmax(0, 1fr); align-items: center; gap: 7px; min-height: 36px; padding: 7px 10px; border: 0; border-radius: 5px; color: #52605d; background: transparent; cursor: pointer; font-size: 13px; text-align: left; }
.manual__nav nav button:hover { color: #17201f; background: #f0f5f3; }
.manual__nav nav button.active { color: #0e6158; background: #dff2ee; font-weight: 600; }
.manual__content { height: calc(100vh - var(--cl-header-height) - var(--cl-tabs-view-height)); overflow: auto; padding: 28px clamp(20px, 4vw, 54px) 40px; scroll-behavior: smooth; }
.hero { display: flex; justify-content: space-between; gap: 30px; max-width: 1080px; margin: 0 auto 22px; padding-bottom: 24px; border-bottom: 1px solid #dce4e1; }
.hero h2 { margin: 7px 0 9px; color: #17201f; font-size: 26px; line-height: 1.35; }
.hero p { max-width: 710px; margin: 0; color: #65716e; font-size: 14px; line-height: 1.75; }
.version { flex: 0 0 205px; padding-left: 18px; border-left: 3px solid #167d70; }
.version span, .version small { display: block; color: #77817f; font-size: 11px; }
.version strong { display: block; margin: 4px 0; color: #17201f; font-size: 15px; }
.section { max-width: 1080px; margin: 0 auto 20px; scroll-margin-top: 18px; border: 1px solid #dce4e1; border-radius: 8px; background: #fff; }
.section__head { display: flex; gap: 14px; padding: 22px 24px 18px; border-bottom: 1px solid #e7ecea; }
.section__icon { display: grid; flex: 0 0 38px; width: 38px; height: 38px; place-items: center; border-radius: 6px; color: #0e6158; background: #dff2ee; }
.section__head small { color: #9aa3a1; font-size: 11px; font-weight: 700; }
.section__head h3 { margin: 1px 0 4px; color: #17201f; font-size: 19px; }
.section__head p { margin: 0; color: #65716e; font-size: 13px; line-height: 1.65; }
.block { padding: 19px 24px; border-bottom: 1px solid #edf1ef; } .block:last-child { border-bottom: 0; }
.block h4 { margin: 0 0 10px; color: #27322f; font-size: 15px; }
.block ol, .block ul { margin: 0; padding-left: 22px; color: #4d5a57; }
.block li { margin: 7px 0; padding-left: 3px; font-size: 13px; line-height: 1.75; }
.block li::marker { color: #167d70; font-weight: 700; }
.block :deep(code), .note :deep(code) { padding: 2px 5px; border: 1px solid #dfe7e4; border-radius: 4px; color: #0e6158; background: #f3f7f5; font-family: Consolas, "Courier New", monospace; font-size: 12px; }
.block pre { overflow: auto; margin: 12px 0 0; padding: 14px 16px; border: 1px solid #294b46; border-radius: 6px; background: #173f3a; }
.block pre code { padding: 0; border: 0; color: #e3eeeb; background: transparent; font-family: Consolas, "Courier New", monospace; font-size: 12px; line-height: 1.7; white-space: pre; }
.note { display: grid; grid-template-columns: 18px minmax(0, 1fr); gap: 8px; margin-top: 13px; padding: 11px 13px; border-left: 3px solid #167d70; color: #3d5651; background: #edf8f5; font-size: 12px; line-height: 1.7; }
.note.warning { border-left-color: #d98e32; color: #68502e; background: #fff7e9; }
.empty { display: grid; min-height: 280px; place-items: center; align-content: center; gap: 9px; color: #89928f; }
.empty svg { font-size: 32px; } .empty strong { color: #4d5a57; } .empty span { font-size: 12px; }
.manual__content footer { display: flex; align-items: center; gap: 12px; max-width: 1080px; margin: 28px auto 0; color: #65716e; }
.manual__content footer img { width: 34px; height: 34px; }
.manual__content footer strong, .manual__content footer span { display: block; }
.manual__content footer strong { color: #34413e; font-size: 12px; }
.manual__content footer span { margin-top: 2px; font-size: 11px; }
@media (max-width: 900px) {
  .manual { display: block; }
  .manual__nav { position: static; height: auto; border-right: 0; border-bottom: 1px solid #dce4e1; }
  .manual__nav header { padding: 18px 16px 12px; }
  .manual__nav nav { display: flex; overflow-x: auto; padding: 2px 12px 12px; }
  .manual__nav nav button { display: inline-flex; flex: 0 0 auto; white-space: nowrap; }
  .manual__content { height: auto; min-height: calc(100vh - var(--cl-header-height) - var(--cl-tabs-view-height)); overflow: visible; padding: 20px 14px 30px; }
  .hero { display: block; } .version { margin-top: 18px; }
  .section__head, .block { padding-right: 16px; padding-left: 16px; }
}
</style>
