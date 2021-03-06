/****************************************************************************
**
** Copyright (C) 2019 Leonid Manieiev.
** Contact: leonid.manieiev@gmail.com
**
** This file is part of Versality.
**
** Versality is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** Versality is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Versality. If not, see <https://www.gnu.org/licenses/>.
**
****************************************************************************/

// Wrapper, so I can use functionality of QStack in QML
// For back button navigation
#ifndef PAGENAMEHOLDER_H
#define PAGENAMEHOLDER_H

#include <QObject>
#include <QStack>
#include <QString>
#include <QDebug>

class PageNameHolder : public QObject
{
    Q_OBJECT
public:
    explicit PageNameHolder(QObject *parent = nullptr) :
        QObject(parent) { }
    Q_INVOKABLE QString pop()
    {
        if(!this->empty())
        {
            QString poped = pageNames.pop();
            return poped;
        }

        return "";
    }
    Q_INVOKABLE void push(const QString& pageName)
    {
        if(pageNames.isEmpty())
            pageNames.push(pageName);
        else if(pageNames.top() != pageName)
            pageNames.push(pageName);
    }
    Q_INVOKABLE void clear()
    { pageNames.clear(); }
    Q_INVOKABLE bool empty() const
    { return pageNames.empty(); }
private:
    QStack<QString> pageNames;
};

#endif // PAGENAMEHOLDER_H
