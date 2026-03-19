-- Tomcat 任务模板
-- 使用 systemctl 管理 Tomcat10，需要 sudo 权限
-- 部署目录：/var/lib/tomcat10/webapps/

return {
  -- 启动 Tomcat
  {
    name = "Tomcat: 启动",
    builder = function()
      return {
        cmd = { "sudo", "systemctl", "start", "tomcat10" },
        components = { "default" },
      }
    end,
  },

  -- 停止 Tomcat
  {
    name = "Tomcat: 停止",
    builder = function()
      return {
        cmd = { "sudo", "systemctl", "stop", "tomcat10" },
        components = { "default" },
      }
    end,
  },

  -- 重启 Tomcat
  {
    name = "Tomcat: 重启",
    builder = function()
      return {
        cmd = { "sudo", "systemctl", "restart", "tomcat10" },
        components = { "default" },
      }
    end,
  },

  -- 查看 Tomcat 状态
  {
    name = "Tomcat: 状态",
    builder = function()
      return {
        cmd = { "systemctl", "status", "tomcat10" },
        components = { "default" },
      }
    end,
  },

  -- 查看 Tomcat 日志
  {
    name = "Tomcat: 日志",
    builder = function()
      return {
        cmd = { "sudo", "journalctl", "-u", "tomcat10", "-f", "--no-pager" },
        components = { "default" },
      }
    end,
  },

  -- Maven 编译并部署到 Tomcat
  -- 需要在 Maven 项目根目录下执行
  {
    name = "Tomcat: Maven 编译并部署",
    condition = {
      -- 只在有 pom.xml 的目录下显示此任务
      callback = function()
        return vim.fn.filereadable(vim.fn.getcwd() .. "/pom.xml") == 1
      end,
    },
    builder = function()
      local webapps = "/var/lib/tomcat10/webapps/"
      local cwd = vim.fn.getcwd()
      local project = vim.fn.fnamemodify(cwd, ":t")
      return {
        cmd = { "bash", "-c",
          string.format(
            "mvn clean package -DskipTests && sudo cp target/*.war %s%s.war",
            webapps, project
          )
        },
        cwd = cwd,
        components = { "default" },
      }
    end,
  },
}
