AutoFillApp.java主程序 
数据库连接模块 (DatabaseLoader) 
主窗体模块 (MainFrame) 
时间选择模块 (DateSelector) 
数据加载模块 (DataLoader) 
工单匹配型号模块 (OrderMatcher) 
流量计序号匹配合格表模块 (FlowmeterMatcher) 
PDF生成模块 (PdfGenerator) 
PDF预览模块 (PdfPreviewer) 
CSV导出模块 (CsvExporter)

javac -d bin -cp "lib/*" -encoding UTF-8 src/*.java
java -cp ".;bin;lib/*" AutoFillApp

1. AutoFillApp.java 修改

修正了 dataLoader.loadData 调用问题，并确保所有按钮和表格的绑定正确。

import javax.swing.*;
import java.awt.*;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableColumn;
import java.sql.*;

public class AutoFillApp {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            try {
                // 初始化数据库加载器
                DatabaseLoader dbLoader = new DatabaseLoader();

                // 创建主窗体
                MainFrame mainFrame = new MainFrame();
                mainFrame.setVisible(true);

                // 获取表格和按钮
                JTable table = mainFrame.getTable();
                JButton btnLoadData = mainFrame.getBtnLoadData();

                // 按钮事件：加载数据
                btnLoadData.addActionListener(e -> {
                    String sql = "SELECT * FROM LouLv";  // 你可以根据需要自定义SQL查询
                    DataLoader dataLoader = new DataLoader(table);
                    dataLoader.loadData(dbLoader, sql);  // 确保传递 DatabaseLoader 和 SQL 查询
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}

2. MainFrame.java 修改

修正了表格和按钮的显示问题，并确保布局正常。

import javax.swing.*;
import javax.swing.table.*;
import java.awt.*;

public class MainFrame extends JFrame {
    private JTable table;
    private JButton btnLoadData;

    public MainFrame() {
        initialize();
    }

    private void initialize() {
        setTitle("AutoFill 工具");
        setSize(1300, 650);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());  // 确保导入了 BorderLayout

        // 创建表格模型
        String[] columnHeadersCN = {
            "选择", "时间戳", "组名", "工单号", "板号",
            "流量计1", "流量计2", "流量计3", "流量计4",
            "流量计5", "流量计6", "流量计7",
            "流量起始", "流量结束", "流量差值", "流量结果",
            "阀起始", "阀结束", "阀差值", "阀结果"
        };
        
        DefaultTableModel model = new DefaultTableModel(null, columnHeadersCN) {
            @Override
            public Class<?> getColumnClass(int columnIndex) {
                return columnIndex == 0 ? Boolean.class : String.class;
            }
            @Override
            public boolean isCellEditable(int row, int column) {
                return column == 0; // 只有选择列可编辑
            }
        };
        
        table = new JTable(model);
        table.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
        add(new JScrollPane(table), BorderLayout.CENTER);  // 确保导入了 BorderLayout

        // 按钮面板
        JPanel buttonPanel = new JPanel();
        btnLoadData = new JButton("加载数据");
        buttonPanel.add(btnLoadData);
        
        add(buttonPanel, BorderLayout.SOUTH);  // 确保导入了 BorderLayout
    }

    // 获取表格
    public JTable getTable() {
        return table;
    }

    // 获取加载数据按钮
    public JButton getBtnLoadData() {
        return btnLoadData;
    }
}

3. DatabaseLoader.java 修改

确保通过配置文件加载数据库连接，且返回数据库连接对象。

import java.io.*;
import java.sql.*;
import java.util.Properties;

public class DatabaseLoader {
    private String DB_URL;
    private String USER;
    private String PASSWORD;
    
    public DatabaseLoader() {
        loadConfig();
    }

    private void loadConfig() {
        File configFile = new File("AutoFill_config.properties");

        if (configFile.exists()) {
            try (FileInputStream fis = new FileInputStream(configFile)) {
                Properties props = new Properties();
                props.load(fis);

                DB_URL = props.getProperty("dbUrl");
                USER = props.getProperty("dbUser");
                PASSWORD = props.getProperty("dbPassword");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public Connection getConnection() throws SQLException {
        if (DB_URL == null || USER == null || PASSWORD == null) {
            throw new SQLException("数据库连接配置未正确加载！");
        }
        return DriverManager.getConnection(DB_URL, USER, PASSWORD);
    }
}

4. DataLoader.java 修改

DataLoader 类负责从数据库加载数据并填充到表格中。

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.sql.*;

public class DataLoader {
    private JTable table;

    public DataLoader(JTable table) {
        this.table = table;
    }

    public void loadData(DatabaseLoader dbLoader, String sql) {
        try (Connection conn = dbLoader.getConnection()) {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            DefaultTableModel model = (DefaultTableModel) table.getModel();
            model.setRowCount(0);

            while (rs.next()) {
                Object[] row = new Object[20]; // 根据列数调整
                row[0] = false; // 勾选框默认不选中
                for (int i = 1; i < 20; i++) {
                    row[i] = rs.getString(i + 1); // 假设数据库字段顺序与表格字段顺序一致
                }
                model.addRow(row);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, "数据库错误: " + e.getMessage(), "错误", JOptionPane.ERROR_MESSAGE);
        }
    }
}

5. 配置文件 AutoFill_config.properties

请确保配置文件包含正确的数据库连接信息，例如：

dbUrl=jdbc:mysql://localhost:3306/your_db
dbUser=your_username
dbPassword=your_password
